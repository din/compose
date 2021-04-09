import Foundation

final class Storage {
    
    static let idStorage = Storage()
    
    fileprivate static var storages = [AnyHashable : Storage]()
    
    static func storage<Object : Hashable>(for object : Object) -> Storage {
        if let storage = storages[object] {
            return storage
        }
        else {
            let storage = Storage()
            storages[object] = storage
            return storage
        }
    }
    
    static func removeStorage<Object : Hashable>(for object : Object) {
        storages[object] = nil
    }
 
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
        return values[key] != nil
    }
    
}
