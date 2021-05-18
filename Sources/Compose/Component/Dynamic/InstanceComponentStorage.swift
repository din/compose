import Foundation
import Combine

final class InstanceComponentStorage<T : Component> {
    
    var components = [UUID : T]()
    var cancellables = [UUID : Set<AnyCancellable>]()
    
    var currentId : UUID? = nil
    
    deinit {
        destroyAll()
    }
    
    func create(allocator : () -> T) {
        let component = allocator()
        
        ObservationBag.shared.beginMonitoring { cancellable in
            self.cancellables[component.id]?.insert(cancellable)
        }
        
        self.cancellables[component.id] = []
        self.components[component.id] = component.bind()
        self.currentId = component.id
        
        ObservationBag.shared.endMonitoring()
    }
    
    func destroy(id : UUID) {
        cancellables[id]?.forEach {
            $0.cancel()
        }
                
        cancellables[id] = nil
        components[id] = nil
    }
    
    fileprivate func destroyAll() {
        let ids = Array(components.keys)
        
        ids.forEach {
            destroy(id: $0)
        }
    }
}
