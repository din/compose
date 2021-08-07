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
        
        withIntrospection {
            Introspection.shared.updateDescriptor(forEmitter: self.id) {
                $0?.fireTime = CFAbsoluteTimeGetCurrent()
                $0?.valueDescription = String(describing: value)
            }
        }
    }
    
}

extension ValueEmitter {
 
    @discardableResult
    public func observeChange(handler : @escaping (Value, Value) -> Void) -> AnyCancellable {
        let observer = Observer<Self, Value> { value in
            guard let oldValue = self.lastValue else {
                return
            }
            
            handler(value, oldValue)
        }
        
        ObservationBag.shared.add(observer, for: id)

        return observer.cancellable
    }
    
    @discardableResult
    public static func ~+=(lhs : ValueEmitter, rhs : @escaping (Value, Value) -> Void) -> AnyCancellable {
        lhs.observeChange(handler: rhs)
    }
    
}
