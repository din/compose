import Foundation

public struct ComponentDescriptor : Codable {
    
    enum CodingKeys : CodingKey {
        case id, lifecycle, name, isVisible, children, emitters
    }
    
    public enum Lifecycle : String, Codable {
        case `static`
        case `dynamic`
        case instance
    }
    
    ///ID of bound component.
    public let id : UUID
    
    ///Lifecycle of component.
    public let lifecycle : Lifecycle
    
    ///Type of component.
    public let name : String
    
    ///Whether the component is visible (in the view hierarchy) or not.
    public var isVisible : Bool = false
    
    ///All children components.
    public fileprivate(set) var children = [String : UUID]()
    
    ///Routers that exist in a bound component with respective declared names of these routers.
    fileprivate(set) var routers = NSMapTable<NSString, Router>.strongToWeakObjects()
    
    ///Emitters and their respective names
    fileprivate(set) var emitters = [String : UUID]()
    
    ///Adds router for a specified router name defined by the user.
    func add(router : Router, for name : String) {
        routers.setObject(router, forKey: name as NSString)
    }
    
    ///Adds an emitter.
    mutating func add(emitter : AnyEmitter, for name : String) {
        emitters[name] = emitter.id
    }
    
    ///Adds a child with specified name.
    mutating func add(component : Component, for name : String) {
        children[name] = component.id
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
