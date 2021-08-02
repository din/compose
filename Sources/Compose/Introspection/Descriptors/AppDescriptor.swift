import Foundation

public struct AppDescriptor : Codable, Equatable {
    
    public let name : String
    
    public internal(set) var startupComponentId : UUID
    
    public internal(set) var components : [UUID : ComponentDescriptor]
    public internal(set) var services : [UUID : ServiceDescriptor]
    public internal(set) var emitters : [UUID : EmitterDescriptor]
    public internal(set) var observers : [UUID : ObserverDescriptor]
    public internal(set) var routers : [UUID : RouterDescriptor]
    public internal(set) var stores : [UUID : StoreDescriptor]
    
}

extension AppDescriptor {
    
    public static var empty : AppDescriptor {
        .init(name: Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Untitled App",
              startupComponentId: UUID(),
              components: [:],
              services: [:],
              emitters: [:],
              observers: [:],
              routers: [:],
              stores: [:])
    }
    
}
