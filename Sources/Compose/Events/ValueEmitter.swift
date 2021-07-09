import Foundation
import Combine
import SwiftUI


public struct ValueEmitter<Value> : Emitter {
    
    fileprivate class Storage {
        var lastValue : Value? = nil
    }

    public let id = UUID()

    public var publisher: AnyPublisher<Value, Never> {
        subject
            .eraseToAnyPublisher()
    }
    
    public var lastValue : Value? {
        storage.lastValue
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
        let cancellable = publisher.sink { value in
            guard let oldValue = self.lastValue else {
                return
            }
            
            handler(value, oldValue)
        }
        
        ObservationBag.shared.add(cancellable, for: id)
         
        return cancellable
    }
    
    @discardableResult
    public static func ~+=(lhs : ValueEmitter, rhs : @escaping (Value, Value) -> Void) -> AnyCancellable {
        return lhs.observeChange(handler: rhs)
    }
    
}
