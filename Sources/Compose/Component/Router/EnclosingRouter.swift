import SwiftUI

@propertyWrapper public struct EnclosingRouter {

    public var wrappedValue : Router {
        router
    }

    let router = Router()

    public init() {

    }

}

extension EnclosingRouter {

    public class Router {

        fileprivate var router : Compose.Router? {
            guard let id = componentId else {
                return nil
            }
            
            return RouterStorage.storage(forComponent: id)?.enclosing
        }

        fileprivate var componentId : UUID? = nil

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
