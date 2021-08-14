import Foundation

public struct ComponentDescriptor : Codable, Identifiable {
    
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
        case service
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
    public fileprivate(set) var children = Set<UUID>()
    
    ///Routers that exist in a bound component with respective declared names of these routers.
    public fileprivate(set) var routers = Set<UUID>()
    
    ///Emitters and their respective names.
    public fileprivate(set) var emitters = Set<UUID>()
    
    ///Emitters and their respective names.
    public fileprivate(set) var stores = Set<UUID>()
    
    ///Observers and their respective emitters.
    ///TODO: move to emitters descriptor.
    public var observers = Set<UUID>()

    ///Component binding time.
    public var bindingTime : CFTimeInterval = 0
    
    ///Observing time.
    public var observingTime : CFTimeInterval = 0
    
    ///Component lifetime.
    public var createdAtTime : CFTimeInterval = 0

    /* Runtime non-codable objects */

    ///Adds router for a specified router name defined by the user.
    mutating func add(router : Router) {
        routers.insert(router.id)
    }
    
    ///Adds an emitter.
    mutating func add(emitter : AnyEmitter) {
        emitters.insert(emitter.id)
    }
    
    ///Adds a store.
    mutating func add(store : AnyStore) {
        stores.insert(store.id)
    }
    
    ///Adds a child with specified name.
    mutating func add(component : Component) {
        add(component: component.id)
    }
    
    ///Adds a child with specified name
    mutating func add(component id : UUID) {
        children.insert(id)
    }
    
    ///Removes a child with specified name
    mutating func remove(component id : UUID) {
        children.remove(id)
    }
    
}

extension ComponentDescriptor : Equatable {
    
    public static func == (lhs: ComponentDescriptor, rhs: ComponentDescriptor) -> Bool {
        lhs.id == rhs.id
    }
    
}

extension ComponentDescriptor : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        "ComponentDescriptor(\(name), id=\(id), lifecycle=\(lifecycle.rawValue), children=\(children.count), emitters=\(emitters.count), routers=\(routers.count), visible: \(isVisible)"
    }
    
}
