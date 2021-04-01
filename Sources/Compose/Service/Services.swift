import Foundation

public final class Services {
    
    public static let all = Services()
    
    internal var services = [String : Service]()
    
    private init() {
        
    }
    
    public subscript<K : Service>(key: K.Type) -> K {
        get {
            if let someService = services[K.Name] {
                if let service = someService as? K {
                    return service
                }
                else {
                    fatalError("Cannot find service with a specified name.")
                }
            }
            else {
                let service = K.init()
                services[K.Name] = service
                
                return service
            }
        }
        set {
            services[K.Name] = newValue
        }
    }
    
    public func bind<K : Service>(_ serviceType : K.Type) {
        _ = self[K]
    }
    
}
