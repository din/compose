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
    
    @Published public var isPresented : Bool = false {
        
        didSet {
            if isPresented == false && options.shouldClearWhenNotPresented == true {
                clear()
            }
        }
        
    }
    
    @Published public var isInteractiveTransitionEnabled : Bool = true
    
    public var target : Component?
    internal let options : RouterOptions

    @Published internal var routes = [Route]() {
    
        didSet {
            withIntrospection {
                Introspection.shared.updateDescriptor(forRouter: self.id) {
                    $0?.routes = self.routes.map { $0.id }
                }
            }
            
            updateFocused()
        }
        
    }
    
    @Published internal var isPushing : Bool = false

    internal let id = UUID()
    internal let start : AnyKeyPath?
    
    fileprivate var zIndex : Int64 = 0
    
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
        zIndex += 1
        
        guard let route = route(for: keyPath) else {
            return
        }
        
        RouterStorage.storage(forComponent: route.id)?.enclosing = self
        
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
        
        zIndex = 0
        
        let change = { [weak self] in
            guard let self = self else {
                return
            }
            
            guard let route = self.routes.first, self.routes.count > 1 else {
                return
            }
            
            self.routes = [route]
        }
        
        guard animated == true else {
            change()
            return
        }
        
        withAnimation(.easeOut(duration: 0.25)) {
            change()
        }
    }
    
    public func replace(_ keyPath : AnyKeyPath, animated : Bool = false) {
        zIndex = 0

        guard let route = route(for: keyPath) else {
            return
        }
        
        RouterStorage.storage(forComponent: route.id)?.enclosing = self
        
        let change = { [weak self] in
            self?.routes = [route]
            self?.didReplace.send(keyPath)
        }
        
        guard animated == true else {
            change()
            return
        }
        
        withAnimation {
            change()
        }
    }
    
    public func clear() {
        zIndex = 0
        
        self.routes = []
    }
    
    fileprivate func route(for keyPath : AnyKeyPath) -> Route? {
        guard let component = target[keyPath: keyPath] as? Component else {
            print("[Compose] Router is unable to find component under keypath: '\(keyPath)'.")
            return nil
        }
        
        return Route(id: (component as? AnyContainerComponent)?.containeeId ?? component.id,
                     view: AnyView(component.view),
                     path: keyPath,
                     zIndex: Double(zIndex))
    }
    
}

extension Router : Bindable {
    
    public func bind<C : Component>(to component: C) {
        self.target = component

        if let start = start {
            replace(start)
        }
        
        RouterStorage.storage(forComponent: component.id)?
            .registered
            .setObject(self, forKey: self.id.uuidString as NSString)
    }
    
}

