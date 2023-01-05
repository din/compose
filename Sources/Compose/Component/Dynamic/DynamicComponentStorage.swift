import Foundation
import Combine

final class DynamicComponentStorage {
    
    let didCreateInstance = ValueEmitter<UUID>()
    let didDestroyInstance = ValueEmitter<UUID>()
 
    fileprivate(set) var controllerIds = [UUID]()
    fileprivate var controllers = [UUID : ComponentController]()
    
    fileprivate var cancellables = [UUID : AnyCancellable]()
    
    init() {
        
    }
    
    deinit {
        destroyAll()
    }
    
}

extension DynamicComponentStorage {
    
    func create<T : Component>(allocator : () -> T) {
        let component = allocator()
        
        let controller = component.bind()
        
        controllers[component.id] = controller
        controllerIds.append(component.id)
        
        cancellables[component.id] = controller.didMoveOutOfParent.sink { [weak self] in
            self?.destroy(id: component.id)
        }
        
        didCreateInstance.send(component.id)
    }
    
}

extension DynamicComponentStorage {
    
    var lastController : ComponentController? {
        guard let id = controllerIds.last else {
            return nil
        }
        
        return controller(for: id)
    }
    
    func controller(for id : UUID) -> ComponentController? {
        return controllers[id]
    }
    
}

extension DynamicComponentStorage {
    
    func destroy(id : UUID) {
        controllers[id] = nil
        controllerIds = controllerIds.filter { $0 != id }
        
        cancellables[id]?.cancel()
        cancellables[id] = nil
    }
    
    fileprivate func destroyAll() {
        controllerIds.forEach {
            destroy(id: $0)
        }
    }
}

