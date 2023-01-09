import Foundation
import SwiftUI

protocol AnyDynamicComponent {
    
    var storage : DynamicComponentStorage { get }
    
    var didCreateInstance : ValueEmitter<UUID> { get }
    var didDestroyInstance : ValueEmitter<UUID> { get }
    
}

@dynamicMemberLookup
public struct DynamicComponent<T : Component> : Component, AnyDynamicComponent {
    
    public let id = UUID()
    
    public var didCreateInstance : ValueEmitter<UUID> {
        storage.didCreateInstance
    }
    
    public var didDestroyInstance : ValueEmitter<UUID> {
        storage.didDestroyInstance
    }
    
    public var observers: Void {
        None
    }
    
    var componentIds: [UUID] {
        storage.controllerIds
    }
    
    let storage = DynamicComponentStorage()
    
    public init() {
       
    }
    
}

extension DynamicComponent {
    
    public func create(_ allocator : () -> T) {
        storage.create(allocator: allocator)
    }
    
    public subscript<V>(dynamicMember keyPath : KeyPath<T, V>) -> V {
        guard let controller = storage.lastController, let component = controller.component as? T else {
            fatalError("[InstanceComponent] Attempting to get property of \(T.self) without creating it first.")
        }
        
        return component[keyPath: keyPath]
    }
    
    public func instance(for id : UUID) -> T? {
        storage.controller(for: id)?.component as? T
    }
    
    public var lastInstance : T? {
        storage.lastController?.component as? T
    }
    
    public var isCreated : Bool {
        lastInstance != nil
    }
    
}

extension DynamicComponent {
    
    public var view: AnyView {
        #if DEBUG
        AnyView(ZStack {
            Text("Missing dynamic component's contents. Did you forget to call 'create' first?")
        })
        #else
        AnyView(EmptyView())
        #endif
    }
    
}
