import Foundation

public struct AppDescriptor : Codable, Equatable {
    
    public let name : String
    
    public let startupComponentId : UUID
    public let components : [UUID : ComponentDescriptor]
    public let emitters : [UUID : EmitterDescriptor]
    
}

extension AppDescriptor {
    
    public static var empty : AppDescriptor {
        .init(name: "", startupComponentId: UUID(), components: [:], emitters: [:])
    }
    
}
