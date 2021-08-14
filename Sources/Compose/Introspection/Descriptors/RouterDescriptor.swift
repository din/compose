import Foundation

public struct RouterDescriptor : Codable, Equatable, Identifiable {

    ///Router descriptor ID.
    public let id : UUID
    
    ///Name of a router.
    public let name : String
    
    ///Has default content or not.
    public let hasDefaultContent : Bool
    
    ///Displayed routes.
    public var routes = [UUID]()

}
