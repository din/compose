import Foundation

public struct Referred<T : Identifiable & Codable & Equatable> : Identifiable {
    
    public let id : T.ID
    
    init(id : T.ID) {
        self.id = id
    }
    
    public static func `for`(_ object : T) -> Referred<T> {
        let ref = Ref(wrappedValue: object)
        ref.wrappedValue = object
        
        return .init(id: object.id)
    }
    
}

