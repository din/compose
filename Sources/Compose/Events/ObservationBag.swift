import Foundation
import Combine

final class ObservationBag {
    
    typealias Monitor = (AnyObserver) -> Void
    
    static let shared = ObservationBag()
    
    var observers = [UUID : [AnyObserver]]()
    var owners = [UUID : [UUID]]()
    var monitors = [UUID : Monitor]()
    
    func add<O : Observer<E, V>, V, E : Emitter>(_ observer : O, for identifier : UUID) {
        if observers[identifier] == nil {
            observers[identifier] = .init()
        }

        observers[identifier]?.append(observer)
        
        withIntrospection {
            Introspection.shared.register(observer: observer,
                                          emitterId: identifier)
            
            Introspection.shared.updateDescriptor(forEmitter: identifier) {
                $0?.observers.insert(observer.id)
            }
            
            Introspection.shared.updateDescriptor(forObserver: observer.id) {
                $0?.componentId = Introspection.shared.observationScope
            }
        }
        
        monitors.values.forEach {
            $0(observer)
        }
    }
    
    func remove(for identifier : UUID) {
        observers[identifier]?.forEach {
            $0.cancel()
        }

        observers[identifier] = nil
    }
    
    func remove(forOwner identifier : UUID) {
        guard let ids = owners[identifier] else {
            return
        }
        
        for id in ids {
            remove(for: id)
        }
        
        owners[identifier] = nil
    }
    
}

extension ObservationBag {
    
    func addOwner(_ ownerId : UUID, for id : UUID) {
        if owners[ownerId] == nil {
            owners[ownerId] = .init()
        }
        
        owners[ownerId]?.append(id)
    }
    
}

extension ObservationBag {
    
    func beginMonitoring(with monitor : @escaping Monitor) -> UUID {
        let key = UUID()
        
        self.monitors[key] = monitor
        
        return key
    }
    
    func endMonitoring(key : UUID) {
        self.monitors[key] = nil
    }
}
