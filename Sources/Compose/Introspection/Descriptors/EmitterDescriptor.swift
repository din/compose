import Foundation

public struct EmitterDescriptor : Codable, Equatable {
    
    ///ID of an emitter.
    let id : UUID
    
    ///Value type description.
    let description : String
    
    ///Observers map.
    var observers = [ObserverDescriptor]()
    
    ///Last changed time.
    var fireTime : CFTimeInterval = .zero
    
    ///Last value description.
    var valueDescription : String
    
}
