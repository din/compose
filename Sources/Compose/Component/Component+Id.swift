import Foundation

extension Component {
    
    public var id : UUID {
        if let id = Storage.idStorage.value(at: String(describing: self)) as? UUID {
            return id
        }
        else {
            let id = UUID()
            Storage.idStorage.setValue(id, at: String(describing: self))
            return id
        }
    }
    
}
