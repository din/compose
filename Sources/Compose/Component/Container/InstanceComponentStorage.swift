import Foundation
import Combine

final class InstanceComponentStorage<T : Component> {
    
    let didCreate = ValueEmitter<UUID>()
    let didDestroy = ValueEmitter<UUID>()
    
    var components = [UUID : T]()
    fileprivate var observers = [UUID : [AnyObserver]]()

    var currentId : UUID? = nil
    
    deinit {
        destroyAll()
    }
    
    @discardableResult
    func create(allocator : () -> T) -> UUID {
        let component = allocator()
        
        let monitoringId = ObservationBag.shared.beginMonitoring { cancellable in
            self.observers[component.id]?.append(cancellable)
        }
        
        observers[component.id] = []
        components[component.id] = component.bind()
        currentId = component.id
  
        ObservationBag.shared.endMonitoring(key: monitoringId)
        
        return component.id
    }
    
    func destroy(id : UUID) {
        components[id] = nil
        
        ObservationBag.shared.remove(forOwner: id)
       
        let enumerator = RouterStorage.storage(forComponent: id)?.registered.objectEnumerator()
        
        while let router = enumerator?.nextObject() as? Router {
            router.target = nil
            router.routes.removeAll()
            
            ObservationBag.shared.remove(for: router.didPush.id)
            ObservationBag.shared.remove(for: router.didPop.id)
            ObservationBag.shared.remove(for: router.didReplace.id)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.observers[id]?.forEach {
                $0.cancel()
            }
            
            self?.observers[id] = nil
        }
        
        withIntrospection {
            Introspection.shared.unregister(component: id)
        }
    }
    
    fileprivate func destroyAll() {
        let ids = Array(components.keys)
        
        ids.forEach {
            destroy(id: $0)
        }
        
        ObservationBag.shared.remove(for: didCreate.id)
        ObservationBag.shared.remove(for: didDestroy.id)
    }
}
