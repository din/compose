import Foundation

public protocol AnyState : Codable, Equatable {
    init()
}

extension AnyState {
    
    public var services : Services {
        return Services.all
    }
    
}
