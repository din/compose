import Foundation

public class AppDescriptor : Codable, ObservableObject {
    
    public let name : String
    
    public internal(set) var startupComponentId = UUID() {
        
        didSet {
            objectWillChange.send()
        }
        
    }
    
    public internal(set) var components = [UUID : ComponentDescriptor]() {
        
        didSet {
            objectWillChange.send()
        }
        
    }
    
    public internal(set) var emitters = [UUID : EmitterDescriptor]() {
        
        didSet {
            objectWillChange.send()
        }
        
    }
    
    public internal(set) var observers = [UUID : ObserverDescriptor]() {
        
        didSet {
            objectWillChange.send()
        }
        
    }
    
    public internal(set) var routers = [UUID : RouterDescriptor]() {
        
        didSet {
            objectWillChange.send()
        }
        
    }
    
    public internal(set) var stores = [UUID : StoreDescriptor]() {
        
        didSet {
            objectWillChange.send()
        }
        
    }
    
    public init() {
        self.name = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Untitled App"
    }
    
}

extension AppDescriptor : Equatable {
 
    public static func == (lhs: AppDescriptor, rhs: AppDescriptor) -> Bool {
        lhs.startupComponentId == rhs.startupComponentId &&
            lhs.components == rhs.components &&
            lhs.emitters == rhs.emitters &&
            lhs.observers == rhs.observers &&
            lhs.routers == rhs.routers &&
            lhs.stores == rhs.stores
    }
    
}
