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
        if Introspection.shared.isEnabled == true {
            let monitorId = ObservationBag.shared.beginMonitoring { observer in
                Introspection.shared.updateDescriptor(forObserver: self.id) {
                    $0?.children.insert(observer.id)
                }
            }
            
            action(input)
            
            ObservationBag.shared.endMonitoring(key: monitorId)
        }
        else {
            action(input)
        }
        
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        
    }
    
    func cancel() {
        withIntrospection {
            Introspection.shared.unregister(observer: id)
        }
        
        subscription?.cancel()
        subscription = nil
    }
}
