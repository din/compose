import Foundation
import SwiftUI
import Combine

public final class Router : ObservableObject, ComponentEntry {
    
    enum Action {
        case push(Bool)
        case pop(Bool)
        case popToRoot(Bool)
        case replace(Bool)
        case clear
        
        var isAnimated : Bool {
            switch self {
                
            case .push(let animated), .pop(let animated), .popToRoot(let animated), .replace(let animated):
                return animated
                
            default:
                return false
                
            }
        }
    }
    
    public var path : AnyKeyPath? {
        paths.last
    }
    
    public var paths : [AnyKeyPath] {
        routes.map { $0.keyPath }
    }
    
    public var isInteractiveTransitionEnabled : Bool = true
    
    public let id = UUID()
    
    internal var routes : [Route] = []
    
    internal let didPerformAction = PassthroughSubject<Action, Never>()

    internal let start : AnyKeyPath?
    
    public init() {
        self.start = nil
        self.routes = []
    }
    
    public init(start : AnyKeyPath) {
        self.start = start
        self.routes = [.init(ownerId: nil, keyPath: start)]
    }
}

extension Router {
    
    public func push(_ keyPath : AnyKeyPath, animated : Bool = true) {
        routes.append(.init(ownerId: self.parentController?.id, keyPath: keyPath))
        didPerformAction.send(.push(animated))
    }
    
    public func pop(animated : Bool = true) {
        guard paths.count > 0 else {
            return
        }
        
        routes.removeLast()
        didPerformAction.send(.pop(animated))
    }
    
    public func popToRoot(animated : Bool = false) {
        guard paths.count > 0 else {
            return
        }
        
        guard let route = routes.first, routes.count > 1 else {
            return
        }
        
        routes = [route]
        didPerformAction.send(.popToRoot(animated))
    }
    
    public func replace(_ keyPath : AnyKeyPath, animated : Bool = false) {
        routes = [.init(ownerId: self.parentController?.id, keyPath: keyPath)]
        didPerformAction.send(.replace(animated))
    }
    
    public func clear() {
        self.routes = []
        didPerformAction.send(.clear)
    }
    
    func controller(for route : Route) -> ComponentController? {
        var target : Component? = nil
        
        if let ownerId = route.ownerId {
            target = ComponentControllerStorage.shared.controllers[ownerId]?.component
        }
        else {
            target = parentController?.component
        }
        
        guard let target = target else {
            print("[CCR] Warning: router is unbound. No components could be looked up.")
            return nil
        }

        guard let component = target[keyPath: route.keyPath] as? Component else {
            print("[CCR] Warning: router is unable to find component under keypath: '\(route.keyPath)'.")
            return nil
        }
        
        if let dynamicComponent = component as? AnyDynamicComponent, let controller = dynamicComponent.storage.lastController {            
            return controller
        }
        else {
            return component.controller
        }
    }
    
}

