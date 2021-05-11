import Foundation
import Combine

extension Storage {
    
    struct RouterObjectKey : Hashable {
        let id : AnyKeyPath
        let keyPath = \Router.self
    }
    
}

@propertyWrapper public class RouterObject : ObservableObject {
    
    public var wrappedValue : Router {
        guard let value = Storage.shared.value(at: Storage.RouterObjectKey(id: path)) as? Router else {
            fatalError("Parent router with the specified parent component type must exist on a view.")
        }
        
        return value
    }
    
    fileprivate let path : AnyKeyPath
    
    public init<T : Component>(_ path : PartialKeyPath<T>) {
        self.path = path
    }
    
}
