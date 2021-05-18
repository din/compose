import Foundation
import SwiftUI

public final class Router : ObservableObject {
    
    public var path : AnyKeyPath? {
        paths.last
    }
    
    public var paths : [AnyKeyPath] {
        routes.map { $0.path }
    }
        
    public let didPush = ValueEmitter<AnyKeyPath>()
    public let didPop = ValueEmitter<AnyKeyPath>()
    public let didReplace = ValueEmitter<AnyKeyPath>()
    
    public var target : Component?
    internal let options : RouterOptions

    @Published internal var routes = [Route]()
    @Published internal var isPushing : Bool = false

    internal let id = UUID()
    
    fileprivate let start : AnyKeyPath?
    
    public init(start : AnyKeyPath, options : RouterOptions = .init()) {
        self.start = start
        self.options = options
    }
    
    public init(options : RouterOptions = .init()) {
        self.start = nil
        self.options = options
    }
    
}

extension Router {
    
    public func push(_ keyPath : AnyKeyPath, animated : Bool = true) {
        guard let route = route(for: keyPath) else {
            return
        }
  
        guard animated == true else {
            self.routes.append(route)
            self.didPush.send(keyPath)
            return
        }
        
        withAnimation(.easeOut(duration: 0.28)) {
            self.routes.append(route)
            self.isPushing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.29) { [weak self] in
            self?.isPushing = false
            self?.didPush.send(keyPath)
        }
    }
    
    public func pop(animated : Bool = true) {
        guard self.paths.count > 0 else {
            return
        }
        
        let change = { [weak self] in
            guard let self = self else {
                return
            }
            
            let route = self.routes.removeLast()

            self.didPop.send(route.path)
        }
        
        guard animated == true else {
            change()
            return
        }

        withAnimation(.easeOut(duration: 0.25)) {
            change()
        }
    }
    
    public func popToRoot(animated : Bool = false) {
        guard self.paths.count > 0 else {
            return
        }
        
        let change = { [weak self] in
            guard let self = self else {
                return
            }
            
            if let start = self.start, let route = self.route(for: start) {
                self.routes = [route]
            }
            else {
                self.routes = []
            }
        }
        
        guard animated == true else {
            change()
            return
        }
        
        withAnimation(.easeOut(duration: 0.25)) {
            change()
        }
    }
    
    public func replace(_ keyPath : AnyKeyPath) {
        guard let route = route(for: keyPath) else {
            return
        }
        
        self.routes = [route]
        didReplace.send(keyPath)
    }
    
    fileprivate func route(for keyPath : AnyKeyPath) -> Route? {
        guard let component = target[keyPath: keyPath] as? Component else {
            print("[Router] Unable to find component under keypath: '\(keyPath)'.")
            return nil
        }
        
        return Route(id: component.id,
                     view: AnyView(component.view
                                    .transition(.move(edge: .trailing))
                                    .environmentObject(self)),
                     path: keyPath,
                     zIndex: Double(routes.count) + 1)
    }
    
}

extension Router : Bindable {
    
    public func bind<C : Component>(to component: C) {
        self.target = component
        
        component.didDisappear += {
            self.target = nil
        }
        
        Storage.shared.setValue(self, at: Storage.RouterObjectKey(id: \C.self))
        
        if let start = start {
            replace(start)
        }
    }
    
}
