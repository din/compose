import Foundation
import Combine

final class InstanceComponentStorage<T : Component> {
    
    var components = [UUID : T]()
    fileprivate var cancellables = [UUID : Set<AnyCancellable>]()
    fileprivate var routers = NSMapTable<NSString, Router>(keyOptions: .copyIn,
                                                           valueOptions: .weakMemory)
    
    var currentId : UUID? = nil
    
    deinit {
        destroyAll()
    }
    
    @discardableResult
    func create(allocator : () -> T) -> UUID {
        let component = allocator()
        
        ObservationBag.shared.beginMonitoring { cancellable in
            self.cancellables[component.id]?.insert(cancellable)
        }
        
        cancellables[component.id] = []
        components[component.id] = component.bind()
        currentId = component.id
        
        routers.setObject((component as? RouterComponent)?.router, forKey: component.id.uuidString as NSString)
        
        ObservationBag.shared.endMonitoring()
        
        return component.id
    }
    
    func destroy(id : UUID) {
        components[id] = nil
        
        routers.object(forKey: id.uuidString as NSString)?.target = nil
        routers.removeObject(forKey: id.uuidString as NSString)
        
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
    }
}
