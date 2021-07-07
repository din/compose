import Foundation

public struct AppDescriptor : Codable {
    
    public let name : String
    
    public let startupComponentId : UUID
    public let components : [UUID : ComponentDescriptor]
    
}
