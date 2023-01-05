import Foundation

struct WeakDictionary<Key : Hashable, Value : AnyObject> {
    
    final class Weak<T : AnyObject> {
        
        weak var value: T?
        
        init(_ value: T) {
            self.value = value
        }
    }
    
    fileprivate var storage = [Key : Weak<Value>]()
    
    subscript(_ key : Key) -> Value? {
        get {
            return storage[key]?.value
        }
        
        set {
            if let newValue = newValue {
                storage[key] = .init(newValue)
            }
            else {
                storage[key] = nil
            }
        }
    }
    
}
