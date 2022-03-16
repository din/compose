import SwiftUI
import Combine

@propertyWrapper public struct EnclosingRouter {

    public var wrappedValue : Router {
        router
    }
    
    public var projectedValue : EnclosingRouter {
        self
    }
    
    public var didCurrentRouteAppear : SignalEmitter {
        router.didCurrentRouteAppear
    }
    
    public var didCurrentRouteDisappear : SignalEmitter {
        router.didCurrentRouteDisappear
    }

    let router = Router()
  
    public init() {

    }

}

extension EnclosingRouter {

    public class Router {

        fileprivate let didCurrentRouteAppear = SignalEmitter()
        fileprivate let didCurrentRouteDisappear = SignalEmitter()
        
        fileprivate var router : Compose.Router? {
            guard let id = componentId else {
                return nil
            }
            
            return RouterStorage.storage(forComponent: id)?.enclosing
        }
        
        fileprivate var componentId : UUID? = nil {
        
            didSet {
                observeRoutes()
            }
            
        }
        
        fileprivate var cancellables = Set<AnyCancellable>()
        
        func observeRoutes() {
            DispatchQueue.main.async {
                self.router?.$routes.sink(receiveValue: { [weak self] routes in
                    if routes.last?.id == self?.componentId {
                        self?.didCurrentRouteAppear.send()
                    }
                    else {
                        self?.didCurrentRouteDisappear.send()
                    }
                })
                .store(in: &self.cancellables)
            }
        }
        
        deinit {
            cancellables.forEach {
                $0.cancel()
            }
            
            cancellables.removeAll()
        }

        public func push<T : Component, V>(_ keyPath : KeyPath<T, V>, animated : Bool = true) {
            let enclosingPaths = Array(router?.paths.reversed() ?? [])
            
            for enclosingPath in enclosingPaths {
                var path : AnyKeyPath = keyPath
                
                if enclosingPath.appending(path: path) == nil {
                    path = \DynamicComponent<T>.[dynamicMember: keyPath]
                }
                
                if enclosingPath.appending(path: path) == nil {
                    path = \InstanceComponent<T>.[dynamicMember: keyPath]
                }
                
                guard let fullPath = enclosingPath.appending(path: path) else {
                    continue
                }
                
                router?.push(fullPath, animated: animated)
                return
            }
            
        
            print("[Compose] Invalid keypath to push to the enclosing router.")
        }
        
        public func pop(animated : Bool = true) {
            router?.pop(animated: animated)
        }
        
    }
    
}

extension EnclosingRouter : Bindable {
    
    public func bind<C>(to component: C) where C : Component {
        router.componentId = component.id
    }
    
}
