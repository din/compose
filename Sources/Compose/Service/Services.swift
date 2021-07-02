import Foundation

public final class Services {
    
    public static let all = Services()
    
    internal var services = [ObjectIdentifier : Service]()
    
    private init() {
        
    }
    
    public subscript<K : Service>(key: K.Type) -> K {
        get {
            if let someService = services[ObjectIdentifier(K.self)] {
                if let service = someService as? K {
                    return service
                }
                else {
                    fatalError("Cannot find service with a specified name.")
                }
            }
            else {
                let service = K.init()
                services[ObjectIdentifier(K.self)] = service
                
                return service
            }
        }
        set {
            services[ObjectIdentifier(K.self)] = newValue
        }
    }

}

extension Service {
    
    public var services : Services {
        Services.all
    }
    
}
