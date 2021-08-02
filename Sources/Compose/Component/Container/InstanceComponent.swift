import Foundation
import SwiftUI

protocol AnyInstanceComponent {
    
}

@dynamicMemberLookup
public struct InstanceComponent<T : Component> : Component, AnyContainerComponent, AnyInstanceComponent {
    
    public let id = UUID()
    
    public var type: Component.Type {
        T.self
    }
    
    public var observers: Void {
        None
    }
    
    public var didCreate : ValueEmitter<UUID> {
        storage.didCreate
    }
    
    public var didDestroy : ValueEmitter<UUID> {
        storage.didDestroy
    }
    
    public var component : T? {
        storage.components[id]
    }
    
    public var isEmpty : Bool {
        storage.components.isEmpty
    }
    
    var containeeId: UUID {
        storage.currentId ?? UUID()
    }

    let storage = InstanceComponentStorage<T>()
    
    public init() {
        // Intentionally left blank
    }
}

extension InstanceComponent {
    
    var componentId : UUID? {
        Storage.shared.value(at: Storage.ComponentIdentifierKey(id: String(describing: self))) as? UUID
    }
    
}

extension InstanceComponent {
    
    public func add(_ allocator : () -> T) {
        let id = storage.create(allocator: allocator)
        didCreate.send(id)
        
        if let componentId = componentId {
            Introspection.shared.updateDescriptor(for: componentId) {
                $0?.add(component: id)
            }
        }
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
        if let id = storage.currentId, let component = storage.components[id] {
            component.view
                .onAppear {
                    
                    if let componentId = componentId {
                        Introspection.shared.updateDescriptor(for: componentId) {
                            $0?.isVisible = storage.components.count > 0
                        }
                    }
                }
                .onDisappear {
                    storage.destroy(id: id)
                    didDestroy.send(id)
                    
                    if let componentId = componentId {
                        Introspection.shared.updateDescriptor(for: componentId) {
                            $0?.isVisible = storage.components.count == 0
                            $0?.remove(component: id)
                        }
                    }
                }
        }
        else {
            emptyBody
        }
    }
    
    private var emptyBody : some View {
        print("[InstanceComponent] Warning component \(T.self) must be set before accessing it.")
        return EmptyView()
    }
    
}
