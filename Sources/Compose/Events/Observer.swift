import Foundation
import Combine

protocol AnyObserver : Cancellable {
    
    var id : UUID { get }
    
}

class Observer<Emitter, Value> : Subscriber, AnyObserver {
    typealias Input = Value
    typealias Failure = Never
    
    let id = UUID()
    let action : (Value) -> Void
    
    var cancellable = AnyCancellable({})
    
    fileprivate var subscription : Subscription? = nil
    
    init(action : @escaping (Value) -> Void) {
        self.action = action
        
        self.cancellable = AnyCancellable { [weak self] in
            self?.cancel()
        }
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
    }
    
    func cancel() {
        subscription?.cancel()
        subscription = nil
    }
}
