import Foundation
import Combine

final class InstanceComponentStorage<T : Component> {
    
    let didCreate = ValueEmitter<UUID>()
    let didDestroy = ValueEmitter<UUID>()
    
    var components = [UUID : T]()
    fileprivate var cancellables = [UUID : Set<AnyCancellable>]()
    fileprivate var bindableObjects = NSMapTable<NSString, NSPointerArray>(keyOptions: .copyIn,
                                                                           valueOptions: .strongMemory)
    
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
        
        var result = BindingResult()
        
        cancellables[component.id] = []
        components[component.id] = component.bind(&result)
        currentId = component.id
        
        bindableObjects.setObject(result.bindableObjects, forKey: component.id.uuidString as NSString)
        
        ObservationBag.shared.endMonitoring(key: monitoringId)
        
        return component.id
    }
    
    func destroy(id : UUID) {
        components[id] = nil
        
        if let objects = bindableObjects.object(forKey: id.uuidString as NSString) {

            objects.allObjects.forEach {
                ($0 as? BindableObject)?.unbind()
            }
            
            for i in 0..<objects.count {
                objects.removePointer(at: i)
            }
        }
        
        bindableObjects.removeObject(forKey: id.uuidString as NSString)
        
        ObservationBag.shared.remove(forOwner: id)
        
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
