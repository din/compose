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
        let observer = Observer<Value>(action: handler)

        publisher.subscribe(observer)
        
        self.parentController?.addObserver(observer, for: self.id)

        return observer.cancellable
    }
    
}

extension Emitter {
    
    @discardableResult
    public static func +=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        lhs.observe(handler: rhs)
    }
    
}

