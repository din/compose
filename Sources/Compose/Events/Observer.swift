import Foundation
import Combine

protocol AnyObserver {
    
    var id : UUID { get }
    
}

class Observer<Value> : Subscriber, Cancellable, AnyObserver {
    typealias Input = Value
    typealias Failure = Never
    
    let id = UUID()
    let action : (Value) -> Void
    
    fileprivate var subscription : Subscription? = nil
    
    init(action : @escaping (Value) -> Void) {
        self.action = action
        
    }
    
    deinit {
        
    }
    
    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Value) -> Subscribers.Demand {
        action(input)
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        subscription?.cancel()
        subscription = nil
    }
    
    func cancel() {
        subscription?.cancel()
        subscription = nil
    }
}
