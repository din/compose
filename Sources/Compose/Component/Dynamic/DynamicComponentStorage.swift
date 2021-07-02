import Foundation
import Combine

final class DynamicComponentStorage<T : Component> {
    
    var component : T? = nil
    
    let didCreate = SignalEmitter()
    let didDestroy = SignalEmitter()
    
    fileprivate var cancellables = Set<AnyCancellable>()
    fileprivate var bindableObjects = NSPointerArray.weakObjects()

    var isCreated : Bool {
        component != nil
    }
    
    deinit {
        destroy()
    }
    
    func create(allocator : () -> T) {
        let monitoringId = ObservationBag.shared.beginMonitoring{ cancellable in
            self.cancellables.insert(cancellable)
        }
    
        var component = allocator()
        
        ObservationBag.shared.addOwner(component.id, for: didCreate.id)
        ObservationBag.shared.addOwner(component.id, for: didDestroy.id)

        var result = BindingResult()
        component = component.bind(&result)
        bindableObjects = result.bindableObjects
        
        self.component = component

        ObservationBag.shared.endMonitoring(key: monitoringId)
    }
    
    func destroy() {
        bindableObjects.allObjects.forEach {
            ($0 as? BindableObject)?.unbind()
        }

        for i in 0..<bindableObjects.count {
            bindableObjects.removePointer(at: i)
        }
        
        if let id = component?.id {
            ObservationBag.shared.remove(forOwner: id)
        }
        
        ObservationBag.shared.remove(for: didCreate.id)
        ObservationBag.shared.remove(for: didDestroy.id)
                
        self.component = nil
     
        DispatchQueue.main.async { [weak self] in
            self?.cancellables.forEach {
                $0.cancel()
            }
            
            self?.cancellables.removeAll()
        }
    }
}
