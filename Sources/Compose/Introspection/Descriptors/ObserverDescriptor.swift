import Foundation

struct ObserverDescriptor : Codable, Equatable {
    
    ///Observer descriptor ID.
    let id : UUID
    
    ///Component that contains the observer.
    var componentId : UUID? = nil
    
    ///Modifiers
    var modifiers = [String]()
    
}
