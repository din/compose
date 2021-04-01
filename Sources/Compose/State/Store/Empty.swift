import Foundation

public final class Empty {
    
    public init() {
        //Intentionally left empty
    }
    
}

extension Empty : AnyStatus {
    
    public static var idle : Empty {
        return Empty()
    }
    
}

extension Empty : AnyValidation {
    
    
}
