import Foundation

public struct ObserverDescriptor : Codable, Equatable, Identifiable {

    ///Observer descriptor ID.
    public let id : UUID
    
    ///Observer type description
    public let description : String
    
    ///Emitter id to which this observer is subscribed to.
    public let emitterId : UUID
    
    ///Parent id to which this observer belongs to.
    public var componentId : UUID? = nil
    
    ///Children of the observer.
    public var children = Set<UUID>()
    
    public init(id: UUID, description: String, emitterId: UUID) {
        self.id = id
        self.description = description
        self.emitterId = emitterId
    }
    
}

