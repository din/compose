import Foundation
import Combine

final class InstanceComponentStorage<T : Component> {
    
    let didCreate = ValueEmitter<UUID>()
    let didDestroy = ValueEmitter<UUID>()
    
    var components = [UUID : T]()
    fileprivate var cancellables = [UUID : Set<AnyCancellable>]()

    var currentId : UUID? = nil
    
    deinit {
        destroyAll()
    }
    
    @discardableResult
    func create(allocator : () -> T) -> UUID {
        let component = allocator()
        
        let monitoringId = ObservationBag.shared.beginMonitoring { cancellable in
            self.cancellables[component.id]?.insert(cancellable)
        }
        
        cancellables[component.id] = []
        components[component.id] = component.bind()
        currentId = component.id
  
        ObservationBag.shared.endMonitoring(key: monitoringId)
        
        return component.id
    }
    
    func destroy(id : UUID) {
        components[id] = nil
        
        ObservationBag.shared.remove(forOwner: id)
       
        Introspection.shared.unregister(component: id)
        
        DispatchQueue.main.async { [weak self] in
            self?.cancellables[id]?.forEach {
                $0.cancel()
            }
            
            self?.cancellables[id] = nil
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
