import Foundation
import Combine

final class ObservationBag {
    
    fileprivate struct Monitor {
        let id = UUID()
        let action : (AnyObserver) -> Void
        let isShallow : Bool
    }
    
    static let shared = ObservationBag()
    
    fileprivate var observers = [UUID : [AnyObserver]]()
    fileprivate var owners = [UUID : [UUID]]()
    fileprivate var monitors = [UUID : Monitor]()
    
    fileprivate var activeMonitors = [UUID]()
    
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
            
            Introspection.shared.updateDescriptor(forComponent: Introspection.shared.observationScopeId) {
                $0?.observers.insert(observer.id)
            }
            
            Introspection.shared.updateDescriptor(forObserver: observer.id) {
                $0?.componentId = Introspection.shared.observationScopeId
            }
            
        }
        
        monitors.values.forEach {
            if $0.isShallow == false {
                $0.action(observer)
            }
            else {
                if $0.id == activeMonitors.last {
                    $0.action(observer)
                }
            }
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
        
        withIntrospection {
            Introspection.shared.updateDescriptor(forEmitter: id) {
                $0?.componentId = ownerId
            }
        }
    }
    
}

extension ObservationBag {
    
    func beginMonitoring(isShallow : Bool = false, with action : @escaping (AnyObserver) -> Void) -> UUID {
        let monitor = Monitor(action: action, isShallow: isShallow)
        
        self.monitors[monitor.id] = monitor
        activeMonitors.append(monitor.id)
        
        return monitor.id
    }
    
    func endMonitoring(key : UUID) {
        self.monitors[key] = nil
        activeMonitors.removeLast()
    }
}
