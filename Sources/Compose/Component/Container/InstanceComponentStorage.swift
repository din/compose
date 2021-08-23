import Foundation
import Combine

final class InstanceComponentStorage<T : Component> {
    
    var components = [UUID : T]()
    var currentId : UUID? = nil
    
    fileprivate let lifecycleEmitterIds : [UUID]
    
    init(lifecycleEmitterIds : [UUID]) {
        self.lifecycleEmitterIds = lifecycleEmitterIds
    }
    
    deinit {
        destroyAll()
    }
    
    @discardableResult
    func create(allocator : () -> T) -> UUID {
        let component = allocator()
        
        components[component.id] = component.bind()
        currentId = component.id
  
        return component.id
    }
    
    func destroy(id : UUID) {
        components[id] = nil

        let enumerator = RouterStorage.storage(forComponent: id)?.registered.objectEnumerator()
   
        while let router = enumerator?.nextObject() as? Router {
            router.target = nil
            router.routes.removeAll()
            
            ObservationTree.shared.node(for: router.didPush.id)?.remove()
            ObservationTree.shared.node(for: router.didPop.id)?.remove()
            ObservationTree.shared.node(for: router.didReplace.id)?.remove()
        }
        
        DispatchQueue.main.async {
            ObservationTree.shared.node(for: id)?.remove()
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
        
        lifecycleEmitterIds.forEach {
            ObservationTree.shared.node(for: $0)?.remove()
        }
    }
}
