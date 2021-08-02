import Foundation

extension Storage {
    
    struct RouterStorageKey : Hashable {
        let id : UUID
    }
    
}

class RouterStorage {
    
    weak var enclosing : Router? = nil
    
    let registered = NSMapTable<NSString, Router>.strongToWeakObjects()
    
}

extension RouterStorage {
    
    static func storage(forComponent id : UUID) -> RouterStorage? {
        Storage.shared.value(at: Storage.RouterStorageKey(id: id)) {
            RouterStorage()
        }
    }
    
}
