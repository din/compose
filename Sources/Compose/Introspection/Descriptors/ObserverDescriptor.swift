import Foundation

struct ObserverDescriptor : Codable, Equatable {
    
    ///Component that contains the observer.
    var componentId : UUID? = nil
    
    ///Modifiers
    var modifiers = [String]()
    
}
