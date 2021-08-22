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
        let observer = Observer<Value>(action: handler)

        publisher.subscribe(observer)

        ObservationTree.shared.currentNode?.addObserver(observer, for: id)
        ObservationTree.shared.node(for: self.id)?.addObserver(observer, for: id)
    
        return observer.cancellable
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
        ObservationTree.shared.currentNode?.addChild(id: self.id)
    }
    
}
