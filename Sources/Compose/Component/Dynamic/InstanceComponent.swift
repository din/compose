import Foundation
import SwiftUI

@dynamicMemberLookup
public struct InstanceComponent<T : Component> : Component {
    
    let storage = InstanceComponentStorage<T>()
    
    public var observers: Void {
        None
    }

    public var id : UUID {
        storage.currentId ?? UUID()
    }
    
    public init() {
        // Intentionally left blank
    }
}

extension InstanceComponent {
    
    public func add(_ allocator : () -> T) {
        storage.create(allocator: allocator)
    }
    
    public subscript<V>(dynamicMember keyPath : KeyPath<T, V>) -> V {
        guard let id = storage.currentId, storage.components[id] != nil else {
            fatalError("[InstanceComponent] Attempting to get property of \(T.self) without creating it first.")
        }
        
        return storage.components[id]![keyPath: keyPath]
    }
    
}

extension InstanceComponent : View {
    
    public var body: some View {
        guard let id = storage.currentId, let component = storage.components[id] else {
            fatalError("[InstanceComponent] Component \(T.self) must be set before accessing it.")
        }
        
        return component.view
            .onDisappear {
                storage.destroy(id: id)
            }
    }
    
}
