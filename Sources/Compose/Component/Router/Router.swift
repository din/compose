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
    
    @Published public var paths : [AnyKeyPath] = []
    @Published public var isInteractiveTransitionEnabled : Bool = true

    public let id = UUID()
    
    internal let didPerformAction = PassthroughSubject<Action, Never>()

    internal let start : AnyKeyPath?
    
    public init() {
        self.start = nil
        self.paths = []
    }
    
    public init(start : AnyKeyPath) {
        self.start = start
        self.paths = [start]
    }
}

extension Router {
    
    public func push(_ keyPath : AnyKeyPath, animated : Bool = true) {
        paths.append(keyPath)
        didPerformAction.send(.push(animated))
    }
    
    public func pop(animated : Bool = true) {
        guard paths.count > 0 else {
            return
        }
        
        paths.removeLast()
        didPerformAction.send(.pop(animated))
    }
    
    public func popToRoot(animated : Bool = false) {
        guard paths.count > 0 else {
            return
        }
        
        guard let path = paths.first, paths.count > 1 else {
            return
        }
        
        paths = [path]
        didPerformAction.send(.popToRoot(animated))
    }
    
    public func replace(_ keyPath : AnyKeyPath, animated : Bool = false) {
        paths = [keyPath]
        didPerformAction.send(.replace(animated))
    }
    
    public func clear() {
        self.paths = []
        didPerformAction.send(.clear)
    }
    
    func controller(for keyPath : AnyKeyPath) -> ComponentController? {
        guard let target = parentController?.component else {
            print("[CCR] Warning: router is unbound. No components could be looked up.")
            return nil
        }

        guard let component = target[keyPath: keyPath] as? Component else {
            print("[CCR] Warning: router is unable to find component under keypath: '\(keyPath)'.")
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

