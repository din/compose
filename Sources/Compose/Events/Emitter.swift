import Foundation
import Combine

infix operator !+=
infix operator ~+=

public protocol AnyEmitter {
    
    var id : UUID { get }
    
}

public protocol Emitter : AnyEmitter, ComponentEntry {
    associatedtype Value

    var publisher : AnyPublisher<Value, Never> { get }
    
    func observe(handler : @escaping (Value) -> Void) -> AnyCancellable
}

extension Emitter {
    
    @discardableResult
    public func observe(handler : @escaping (Value) -> Void) -> AnyCancellable {
        let currentScope = ComponentControllerStorage.shared.currentEventScope
        
        #if DEBUG
        if currentScope == nil && parentController != nil {
            print("[EOB] Warning: observation for \(ComponentControllerStorage.shared.displayName(for: self.id)) without 'withComponentScope' inside asynchonous function will not work.")
        }
        #endif
        
        let cancellable = publisher.sink { [weak currentScope] v in
            if let scope = currentScope {
                ComponentControllerStorage.shared.pushEventScope(for: scope.id)
            }
            
            handler(v)
            
            if currentScope != nil {
                ComponentControllerStorage.shared.popEventScope()
            }
        }
        
        currentScope?.addObserver(cancellable)

        return cancellable
    }
    
}

extension Emitter {
    
    @discardableResult
    public static func +=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        lhs.observe(handler: rhs)
    }
    
}

