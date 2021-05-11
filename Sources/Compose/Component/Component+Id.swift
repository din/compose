import Foundation

extension Storage {

    struct ComponentIdentifierKey : Hashable {
        let id : String
        let keyPath = \Component.self
    }
    
}

extension Component {
    
    public var id : UUID {
        if let id = Storage.shared.value(at: Storage.ComponentIdentifierKey(id: String(describing: self))) as? UUID {
            return id
        }
        else {
            let id = UUID()
            Storage.shared.setValue(id, at: Storage.ComponentIdentifierKey(id: String(describing: self)))
            return id
        }
    }
    
}
