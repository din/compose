import Foundation
import Combine

final class DynamicComponentStorage<T : Component> {
    var component : T? = nil
    var cancellables = Set<AnyCancellable>()
    
    var isCreated : Bool {
        component != nil
    }
    
    deinit {
        destroy()
    }
    
    func create(allocator : () -> T) {
        ObservationBag.shared.beginMonitoring { cancellable in
            self.cancellables.insert(cancellable)
        }
        
        let component = allocator().bind()
        self.component = component
        
        ObservationBag.shared.endMonitoring()
    }
    
    func destroy() {
        cancellables.forEach {
            $0.cancel()
        }
        
        cancellables.removeAll()
        
        if let router = Storage.shared.value(at: Storage.RouterObjectKey(id: \T.self)) as? Router {
            router.target = nil
        }
        
        self.component = nil
    }
}
