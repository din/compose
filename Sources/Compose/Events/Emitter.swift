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
    func observeOnce(handler : @escaping (Value) -> Void) -> AnyCancellable
}

extension Emitter {
    
    @discardableResult
    public func observe(handler : @escaping (Value) -> Void) -> AnyCancellable {
        let cancellable = publisher.sink { value in
            handler(value)
        }
        
        ObservationBag.shared.add(cancellable, for: id)
    
        return cancellable
    }
    
    @discardableResult
    public func observeOnce(handler : @escaping (Value) -> Void) -> AnyCancellable {
        var cancellable : AnyCancellable? = nil

        cancellable = publisher.sink { value in
            handler(value)
            
            if let cancellable = cancellable {
                ObservationBag.shared.remove(for: id)
                cancellable.cancel()
            }
        }
        
        if let cancellable = cancellable {
            ObservationBag.shared.add(cancellable, for: id)
        }
        
        return cancellable ?? AnyCancellable({ })
    }
    
}

extension Emitter {
    
    @discardableResult
    public static func +=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        return lhs.observe(handler: rhs)
    }

    @discardableResult
    public static func !+=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        return lhs.observeOnce(handler: rhs)
    }
    
}

extension Emitter {
    
    public func bind<C>(to component: C) where C : Component {
        ObservationBag.shared.addOwner(component.id, for: id)
    }
    
}
