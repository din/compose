import Foundation

public protocol AnyState : Equatable {
    init()
}

extension AnyState {
    
    public var services : Services {
        return Services.all
    }
    
}
