import Foundation

public struct StoreDescriptor : Codable, Equatable, Identifiable {
    
    ///Store descriptor ID.
    public let id : UUID
    
    ///Name of store.
    public let name : String
    
}
