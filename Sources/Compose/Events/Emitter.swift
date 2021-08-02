import Foundation
import Combine

infix operator !+=
infix operator ~+=

public protocol AnyEmitter : CustomDebugStringConvertible {
    
    var id : UUID { get }
    
}

public protocol Emitter : AnyEmitter, Bindable {
    associatedtype Value

    var publisher : AnyPublisher<Value, Never> { get }
    
    func observe(handler : @escaping (Value) -> Void) -> AnyCancellable
}

extension Emitter {
    
    @discardableResult
    public func observe(handler : @escaping (Value) -> Void) -> AnyCancellable {
        let observer = Observer<Self, Value>(action: handler)

        publisher.subscribe(observer)

        ObservationBag.shared.add(observer, for: id)
    
        return observer.cancellable
    }
    
    public var debugDescription: String {
        String(describing: Value.self)
    }
    
}

extension Emitter {
    
    @discardableResult
    public static func +=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        lhs.observe(handler: rhs)
    }
    
}

extension Emitter {
    
    public func bind<C>(to component: C) where C : Component {
        ObservationBag.shared.addOwner(component.id, for: id)
    }
    
}
