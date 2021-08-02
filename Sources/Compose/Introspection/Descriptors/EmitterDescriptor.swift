import Foundation

public struct EmitterDescriptor : Codable, Equatable, Identifiable {

    ///ID of an emitter.
    public let id : UUID
    
    ///Name of an emitter.
    public let name : String
    
    ///Value type description.
    public let description : String
    
    ///Parent identifier for this emitter.
    public var parentId : UUID? = nil
    
    ///Observers map.
    public var observers = Set<UUID>()
    
    ///Last changed time.
    public var fireTime : CFTimeInterval = .zero
    
    ///Last value description.
    public var valueDescription : String
    
    public init(id: UUID, name: String, description: String, valueDescription : String) {
        self.id = id
        self.name = name
        self.description = description
        self.valueDescription = valueDescription
    }
    
}
