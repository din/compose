import Foundation
import Combine

protocol AnyObserver : Cancellable {
    
    var id : UUID { get }
    
}

struct Observer<Value> : Subscriber, AnyObserver {
    typealias Input = Value
    typealias Failure = Never
    
    fileprivate class Storage {
        
        var cancellable = AnyCancellable({})
        
        var subscription : Subscription? = nil {
            
            didSet {
                cancellable = AnyCancellable { [weak self] in
                    self?.subscription?.cancel()
                    self?.subscription = nil
                }
            }
            
        }
        
    }
    
    var cancellable : AnyCancellable {
        storage.cancellable
    }
    
    let combineIdentifier = CombineIdentifier()
    let id = UUID()
    let action : (Value) -> Void
    
    fileprivate let storage = Storage()
    
    init(action : @escaping (Value) -> Void) {
        self.action = action
    }
    
    func receive(subscription: Subscription) {
        storage.subscription = subscription

        subscription.request(.unlimited)
    }
    
    func receive(_ input: Value) -> Subscribers.Demand {
        action(input)
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        
    }
    
    func cancel() {
        storage.cancellable.cancel()
        storage.cancellable = AnyCancellable({})
    }
}

extension Observer : CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "Observer(id=\(self.id), subscribption=\(storage.subscription.debugDescription))"
    }
    
}
