import Foundation
import Combine

final class DynamicComponentStorage<T : Component> {
    
    var component : T? = nil
    
    let didCreate = SignalEmitter()
    let didDestroy = SignalEmitter()
    
    fileprivate var observers = [AnyObserver]()

    var isCreated : Bool {
        component != nil
    }
    
    deinit {
        destroy()
        
        ObservationBag.shared.remove(for: didCreate.id)
        ObservationBag.shared.remove(for: didDestroy.id)
    }
    
    @discardableResult
    func create(allocator : () -> T) -> UUID {
        let monitoringId = ObservationBag.shared.beginMonitoring{ cancellable in
            self.observers.append(cancellable)
        }
    
        let component = allocator().bind()
        self.component = component

        ObservationBag.shared.endMonitoring(key: monitoringId)
        
        return component.id
    }
    
    @discardableResult
    func destroy() -> UUID? {
        guard let id = component?.id else {
            return nil
        }
    
        ObservationBag.shared.remove(forOwner: id)
        
        let enumerator = RouterStorage.storage(forComponent: id)?.registered.objectEnumerator()
        
        while let router = enumerator?.nextObject() as? Router {
            router.target = nil
            router.routes.removeAll()
            
            ObservationBag.shared.remove(for: router.didPush.id)
            ObservationBag.shared.remove(for: router.didPop.id)
            ObservationBag.shared.remove(for: router.didReplace.id)
        }
     
        self.component = nil
     
        DispatchQueue.main.async { [weak self] in
            self?.observers.forEach {
                $0.cancel()
            }
            
            self?.observers.removeAll()
        }
        
        withIntrospection {
            Introspection.shared.unregister(component: id)
        }
        
        return id
    }
}
