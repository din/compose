import Foundation
import Combine

final class DynamicComponentStorage<T : Component> {
    
    var component : T? = nil

    fileprivate let lifecycleEmitterIds : [UUID]
    
    init(lifecycleEmitterIds : [UUID]) {
        self.lifecycleEmitterIds = lifecycleEmitterIds
    }
    
    deinit {
        destroy()
        
        lifecycleEmitterIds.forEach {
            ObservationTree.shared.node(for: $0)?.remove()
        }
    }
    
    @discardableResult
    func create(allocator : () -> T) -> UUID {
        let component = allocator().bind()
        self.component = component
        return component.id
    }
    
    @discardableResult
    func destroy() -> UUID? {
        guard let id = component?.id else {
            return nil
        }
    
        let enumerator = RouterStorage.storage(forComponent: id)?.registered.objectEnumerator()
        
        while let router = enumerator?.nextObject() as? Router {
            router.target = nil
            router.routes.removeAll()
            
            ObservationTree.shared.node(for: router.didPush.id)?.remove()
            ObservationTree.shared.node(for: router.didPop.id)?.remove()
            ObservationTree.shared.node(for: router.didReplace.id)?.remove()
        }
        
        self.component = nil
     
        DispatchQueue.main.async {
            ObservationTree.shared.node(for: id)?.remove()
        }
        
        withIntrospection {
            Introspection.shared.unregister(component: id)
        }
        
        return id
    }
}
