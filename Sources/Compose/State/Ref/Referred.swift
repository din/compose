import Foundation

public struct Referred<T : Identifiable> : Identifiable {
    
    public let id : T.ID
    
    init(id : T.ID) {
        self.id = id
    }
    
}

