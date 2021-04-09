import Foundation
import Combine

@propertyWrapper public class RouterObject : ObservableObject {
    
    public var wrappedValue : Router {
        guard let value = Storage.storage(for: \Router.self).value(at: path) as? Router else {
            fatalError("Parent router with the specified parent component type must exist on a view.")
        }
        
        return value
    }
    
    fileprivate let path : AnyKeyPath
    
    public init<T : Component>(_ path : PartialKeyPath<T>) {
        self.path = path
    }
    
}
