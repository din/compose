import Foundation
import Combine
import SwiftUI

infix operator ~+=

public struct ValueEmitter<Value> : Emitter {
    
    fileprivate class Storage {
        var lastValue : Value? = nil
    }

    public let id = UUID()

    public var publisher: AnyPublisher<Value, Never> {
        subject
            .eraseToAnyPublisher()
    }
    
    public internal(set) var lastValue : Value? {
        get {
            storage.lastValue
        }
        
         set {
            storage.lastValue = newValue
        }
    }
    
    internal let subject : PassthroughSubject<Value, Never>
    
    fileprivate let storage = Storage()

    public init(_ initial : Value? = nil) {
        self.subject = PassthroughSubject()
    }
    
    public func send(_ value : Value) {
        storage.lastValue = value
        subject.send(value)
    }
    
}

extension ValueEmitter {
 
    @discardableResult
    public func observeChange(handler : @escaping (Value, Value) -> Void) -> AnyCancellable {
        let currentScope = ComponentControllerStorage.shared.currentEventScope
        
        let cancellable = publisher.sink { [weak currentScope] value in
            guard let oldValue = self.lastValue else {
                return
            }
            
            ComponentControllerStorage.shared.pushEventScope(for: currentScope?.id)
            
            handler(value, oldValue)
            
            ComponentControllerStorage.shared.popEventScope()
        }
        
        currentScope?.addObserver(cancellable)

        return cancellable
    }
    
    @discardableResult
    public static func ~+=(lhs : ValueEmitter, rhs : @escaping (Value, Value) -> Void) -> AnyCancellable {
        lhs.observeChange(handler: rhs)
    }
    
}
