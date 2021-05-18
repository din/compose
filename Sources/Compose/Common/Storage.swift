import Foundation

final class Storage {
    
    static let shared = Storage()
    
    var values = [AnyHashable : Any]()
    
    func value<T>(at key : AnyHashable, allocator : () -> T) -> T {
        if let value = values[key] as? T {
            return value
        }
        else {
            let value = allocator()
            values[key] = value
            return value
        }
    }
    
    func value(at key : AnyHashable) -> Any? {
        values[key]
    }
    
    func setValue<T>(_ value : T, at key : AnyHashable) {
        values[key] = value
    }
    
    func hasValue(at key : AnyHashable) -> Bool {
        values[key] != nil
    }
    
    func removeValue(at key : AnyHashable) {
        values[key] = nil
    }
    
}
