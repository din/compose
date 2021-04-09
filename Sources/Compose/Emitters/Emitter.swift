import Foundation
import Combine
import SwiftUI

infix operator !+=
infix operator ++=
infix operator ~+=

public enum ChoiceEmitterValue {
    case failed
    case succeeded
    case cancelled
    case done
}

public typealias SignalEmitter = Emitter<Void>
public typealias CallbackEmitter = Emitter<() -> Void>
public typealias ChoiceEmitter = Emitter<ChoiceEmitterValue>

public class Emitter<Value> {
    
    public let publisher : CurrentValueSubject<Value?, Never>

    internal let id = UUID()
    internal var sinks = Set<AnyCancellable>()
  
    public init(_ initial : Value? = nil) {
        self.publisher = CurrentValueSubject(initial)
    }
    
    public func send(_ value : Value) {
        publisher.send(value)
    }
    
    public func observe(handler : @escaping (Value) -> Void,
                        emitRightAway : Bool = false) {
        let observer = EmitterObserver(handler: handler)
    
        if emitRightAway == false {
            publisher.dropFirst().sink { value in
                guard let value = value else {
                    return
                }
                
                observer.handler?(value)
            }.store(in: &sinks)
        }
        else {
            publisher.sink { value in
                guard let value = value else {
                    return
                }
                 
                observer.handler?(value)
            }.store(in: &sinks)
        }
    }
    
    public func observeOnce(handler : @escaping (Value) -> Void) {
        let observer = EmitterObserver(handler: handler)
        
        var cancellable : AnyCancellable? = nil
        
        cancellable = publisher.dropFirst().sink { [weak self] value in
            guard let value = value else {
                return
            }
            
            observer.handler?(value)

            if let cancellable = cancellable {
                self?.sinks.remove(cancellable)
                cancellable.cancel()
            }
        }
        
        if let cancellable = cancellable {
            sinks.insert(cancellable)
        }
    }

    public func observeChange(handler : @escaping (Value, Value) -> Void) {
        let observer = EmitterObserver(changeHandler: handler)
        
        publisher.dropFirst().sink { value in
            guard let value = value, let oldValue = self.publisher.value else {
                return
            }
            
            observer.changeHandler?(value, oldValue)
        }.store(in: &sinks)
    }
    
    public func configure<Output>(configure : (_ publisher : AnyPublisher<Value?, Never>) -> AnyPublisher<Output, Never>,
                                  observe handler : @escaping (Output) -> Void) {
        let observer = EmitterObserver(handler: handler)
        
        configure(publisher.eraseToAnyPublisher()).sink { value in
            observer.handler?(value)
        }.store(in: &sinks)
    }
    
}

extension Emitter {
    
    public static func +=(lhs : Emitter, rhs : @escaping (Value) -> Void) {
        lhs.observe(handler: rhs)
    }
    
    public static func ++=(lhs : Emitter, rhs : @escaping (Value) -> Void) {
        lhs.observe(handler: rhs, emitRightAway : true)
    }
    
    public static func !+=(lhs : Emitter, rhs : @escaping (Value) -> Void) {
        lhs.observeOnce(handler: rhs)
    }
    
    public static func ~+=(lhs : Emitter, rhs : @escaping (Value, Value) -> Void) {
        lhs.observeChange(handler: rhs)
    }
    
}

extension Emitter {
    
    public var binding : Binding<Value?> {
        .init {
            return self.publisher.value
        } set: { value in
            guard let value = value else {
                return
            }
            
            self.send(value)
        }

    }
    
}

extension Emitter where Value == Void {
    
    public convenience init() {
        self.init(Void())
    }
    
    public func send() {
        self.send(Void())
    }
    
}

