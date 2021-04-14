import Foundation

public final class Empty {
    
    public init() {
        //Intentionally left empty
    }
    
}

extension Empty : AnyStatus, Equatable, Hashable {
   
    public static func == (lhs: Empty, rhs: Empty) -> Bool {
        type(of: lhs) == type(of: rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Self.self))
    }
    
}

extension Empty : AnyValidation {
    
}
