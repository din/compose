import Foundation
import Combine
import SwiftUI

infix operator !+=
infix operator ++=
infix operator ~+=

public typealias SignalEmitter = ValueEmitter<Void>
public typealias CallbackEmitter = ValueEmitter<() -> Void>

public struct ValueEmitter<Value> : Emitter {

    public let id = UUID()
    
    public var publisher: AnyPublisher<Value?, Never> {
        subject.eraseToAnyPublisher()
    }
    
    internal let subject : CurrentValueSubject<Value?, Never>

    public init(_ initial : Value? = nil) {
        self.subject = CurrentValueSubject(initial)
    }
    
    public func send(_ value : Value) {
        subject.send(value)
    }
    
}

extension ValueEmitter {
 
    @discardableResult
    public func observeChange(handler : @escaping (Value, Value) -> Void) -> AnyCancellable {
        let cancellable = publisher.dropFirst().sink { value in
            guard let value = value, let oldValue = self.subject.value else {
                return
            }
            
            handler(value, oldValue)
        }
        
        cancellableStorage.cancellables.insert(cancellable)
        
        return cancellable
    }
    
    @discardableResult
    public static func ~+=(lhs : ValueEmitter, rhs : @escaping (Value, Value) -> Void) -> AnyCancellable {
        return lhs.observeChange(handler: rhs)
    }
    
        
    public static func +(lhs : Self, rhs : Self) -> Emitters.Merge<Self> {
        Emitters.Merge(lhs, rhs)
    }
    
}

extension ValueEmitter where Value == Void {
    
    public init() {
        self.init(Void())
    }
    
    public func send() {
        self.send(Void())
    }
    
}
