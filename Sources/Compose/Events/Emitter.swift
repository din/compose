import Foundation
import Combine

infix operator !+=
infix operator ~+=

public protocol AnyEmitter {
    
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
        let observer = Observer(action: handler)
        let cancellable = AnyCancellable(observer)
        
        publisher.subscribe(observer)

        ObservationBag.shared.add(cancellable, for: id)
    
        return cancellable
    }
    
}

extension Emitter {
    
    @discardableResult
    public static func +=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        return lhs.observe(handler: rhs)
    }
    
}

extension Emitter {
    
    public func bind<C>(to component: C) where C : Component {
        ObservationBag.shared.addOwner(component.id, for: id)
        
        if Introspection.shared.isEnabled == true {
            Introspection.shared.register(emitter: self)
        }
    }
    
}
