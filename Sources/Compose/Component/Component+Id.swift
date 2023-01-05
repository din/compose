import Foundation
import SwiftUI

extension Storage {

    struct ComponentIdentifierKey : Hashable {
        let id : Int
        let keyPath = \Component.self
    }
    
}

extension Component {
    
    public var id : UUID {
        let internalId = String(describing: self).hashValue
        
        if let id = Storage.shared.value(at: Storage.ComponentIdentifierKey(id: internalId)) as? UUID {
            return id
        }
        else {
            let id = UUID()
            Storage.shared.setValue(id, at: Storage.ComponentIdentifierKey(id: internalId))
            return id
        }
    }
    
}

extension SwiftUI.ObservedObject : CustomDebugStringConvertible {
    
    public var debugDescription : String {
        "ObservedObject()"
    }
    
}

