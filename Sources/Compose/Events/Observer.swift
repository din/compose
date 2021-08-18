import Foundation
import Combine

protocol AnyObserver : Cancellable {
    
    var id : UUID { get }
    
}

struct Observer<Value> : Subscriber, AnyObserver {
    typealias Input = Value
    typealias Failure = Never
    
    fileprivate class Storage {
        
        var subscription : Subscription? = nil {
            
            didSet {
                cancellable = AnyCancellable { [weak self] in
                    self?.subscription?.cancel()
                }
            }
            
        }
        
        var cancellable = AnyCancellable({})
        
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
        if Introspection.shared.isEnabled == true {
            let monitorId = ObservationBag.shared.beginMonitoring(isShallow: true) { observer in
                Introspection.shared.updateDescriptor(forObserver: self.id) {
                    $0?.children.insert(observer.id)
                }
                
                if let id = Introspection.shared.descriptor(forObserver: self.id)?.componentId {
                    Introspection.shared.updateDescriptor(forObserver: observer.id) {
                        $0?.componentId = id
                    }
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

        storage.subscription?.cancel()
        storage.subscription = nil
        storage.cancellable = AnyCancellable({})
    }
}

extension Observer : CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "Observer(id=\(self.id), subscribption=\(storage.subscription.debugDescription))"
    }
    
}
