import Foundation
import SwiftUI

@dynamicMemberLookup
public struct DynamicComponent<T : Component> : Component, AnyDynamicComponent {
    
    let storage = DynamicComponentStorage<T>()
    
    public let didCreate = SignalEmitter()
    public let didDestroy = SignalEmitter()
    
    public var observers: Void {
        None
    }
    
    public var component : T? {
        storage.component
    }
    
    public var isCreated : Bool {
        storage.isCreated
    }
    
    public init() {
        // Intentionally left blank
    }
}

extension DynamicComponent {
    
    public func create(_ allocator : () -> T) {
        storage.create(allocator: allocator)
        didCreate.send()
    }
    
    public func destroy() {
        storage.component?.didDisappear.send()
        storage.destroy()
        didDestroy.send()
    }
    
    public subscript<V>(dynamicMember keyPath : KeyPath<T, V>) -> V {
        guard storage.component != nil else {
            fatalError("Attempting to get dynamic component's property without creating it first.")
        }
        
        return storage.component![keyPath: keyPath]
    }
    
}

extension DynamicComponent : View {
    
    public var body: some View {
        guard let component = storage.component else {
            fatalError("DynamicComponent's component must be set before accessing it.")
        }
        
        return component.view
    }
    
}
