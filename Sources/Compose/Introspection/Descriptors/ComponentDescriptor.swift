import Foundation

public struct ComponentDescriptor : Codable, Equatable {
    
    enum CodingKeys : CodingKey {
        case id,
             lifecycle,
             name,
             isVisible,
             children,
             emitters,
             routers,
             stores,
             observers,
             bindingTime,
             observingTime,
             createdAtTime
    }
    
    public enum Lifecycle : String, Codable {
        case `static`
        case container
        case `dynamic`
        case instance
    }

    public enum MemoryStatus {
        case retained
        case deinitialised
    }
    
    ///ID of bound component.
    public let id : UUID
        
    ///Type of component.
    public let name : String
    
    ///Lifecycle of component.
    public var lifecycle : Lifecycle
    
    ///Whether the component is visible (in the view hierarchy) or not.
    public var isVisible : Bool = false
    
    ///All children components.
    public fileprivate(set) var children = [String : UUID]()
    
    ///Routers that exist in a bound component with respective declared names of these routers.
    public fileprivate(set) var routers = [String : UUID]()
    
    ///Emitters and their respective names.
    public fileprivate(set) var emitters = [String : UUID]()
    
    ///Emitters and their respective names.
    public fileprivate(set) var stores = [String : UUID]()
    
    ///Observers and their respective emitters.
    ///TODO: move to emitters descriptor.
    public var observers = [UUID]()
    
    ///Router object instances.
    ///TODO: to be moved to router descriptors.
    fileprivate(set) var routerObjects = NSMapTable<NSString, Router>.strongToWeakObjects()
    
    ///Component binding time.
    public var bindingTime : CFTimeInterval = 0
    
    ///Observing time.
    public var observingTime : CFTimeInterval = 0
    
    ///Component lifetime.
    public var createdAtTime : CFTimeInterval = 0
    
    ///Adds router for a specified router name defined by the user.
    mutating func add(router : Router, for name : String) {
        routers[name] = router.id
        routerObjects.setObject(router, forKey: name as NSString)
    }
    
    ///Adds an emitter.
    mutating func add(emitter : AnyEmitter?, for name : String) {
        emitters[name] = emitter?.id
    }
    
    ///Adds a store.
    mutating func add(store : AnyStore?, for name : String) {
        stores[name] = store?.id
    }
    
    ///Adds a child with specified name.
    mutating func add(component : Component?, for name : String) {
        children[name] = component?.id
    }
    
    ///Adds a child with specified name
    mutating func add(component id : UUID) {
        children[id.uuidString] = id
    }
    
    ///Removes a child with specified name
    mutating func remove(component id : UUID) {
        children[id.uuidString] = nil
    }
    
}

extension ComponentDescriptor : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        "ComponentDescriptor(\(name), id=\(id), lifecycle=\(lifecycle.rawValue), children=\(children.count), emitters=\(emitters.count), routers=\(routers.count), visible: \(isVisible)"
    }
    
}
