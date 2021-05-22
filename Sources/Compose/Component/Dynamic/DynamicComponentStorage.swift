import Foundation
import Combine

final class DynamicComponentStorage<T : Component> {
    
    var component : T? = nil
    
    fileprivate var cancellables = Set<AnyCancellable>()
    fileprivate weak var router : Router? = nil
    
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
        self.router = (component as? RouterComponent)?.router

        ObservationBag.shared.endMonitoring()
    }
    
    func destroy() {
        cancellables.forEach {
            $0.cancel()
        }
        
        router?.target = nil
        cancellables.removeAll()
  
        self.component = nil
    }
}
