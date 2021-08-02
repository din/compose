import Foundation

public struct ServiceDescriptor : Codable, Equatable, Identifiable {
    
    ///Unique identifier of a service.
    public let id : UUID
    
    ///Service name.
    public let name : String
    
    ///Stores.
    public var stores = Set<UUID>()
    
    ///Emitters
    public var emitters = Set<UUID>()
    
}

