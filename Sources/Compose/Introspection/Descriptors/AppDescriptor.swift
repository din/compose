import Foundation

public struct AppDescriptor : Codable, Equatable {
    
    public let name : String
    
    public let startupComponentId : UUID
    public let components : [UUID : ComponentDescriptor]
    
}

extension AppDescriptor {
    
    public static var empty : AppDescriptor {
        .init(name: "", startupComponentId: UUID(), components: [:])
    }
    
}
