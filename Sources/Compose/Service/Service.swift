import Foundation
import Combine

public protocol Service {
    
    static var Name : String { get }
    
    init()
    
}

extension Service {
    
    public var services : Services {
        return Services.all
    }
    
}
