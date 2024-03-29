import Foundation
import SwiftUI

protocol AnyInstanceComponent {
    
    var didCreate : ValueEmitter<UUID> { get }
    var didDestroy : ValueEmitter<UUID> { get }
    
}

@dynamicMemberLookup
public struct InstanceComponent<T : Component> : Component, AnyContainerComponent, AnyInstanceComponent {
    
    public let id = UUID()
    
    public let didCreate = ValueEmitter<UUID>()
    public let didDestroy = ValueEmitter<UUID>()
    
    public var type: Component.Type {
        T.self
    }
    
    public var observers: Void {
        None
    }
    
    public var component : T? {
        guard let id = storage.currentId else {
            return nil
        }
        
        return storage.components[id]
    }
    
    public var isEmpty : Bool {
        storage.components.isEmpty
    }
    
    var containeeId: UUID {
        storage.currentId ?? UUID()
    }
    
    let storage : InstanceComponentStorage<T>

    public init() {
        storage = InstanceComponentStorage<T>(lifecycleEmitterIds: [
            didCreate.id,
            didDestroy.id
        ])
    }

}

extension InstanceComponent {
    
    public func add(_ allocator : () -> T) {
        let id = storage.create(allocator: allocator)
        didCreate.send(id)
        
        Introspection.shared.updateDescriptor(forComponent: self.id) {
            $0?.add(component: id)
        }

        Introspection.shared.updateDescriptor(forComponent: id) {
            $0?.lifecycle = .instance
            $0?.parent = self.id
        }
    }
    
    public subscript<V>(dynamicMember keyPath : KeyPath<T, V>) -> V {
        guard let id = storage.currentId, storage.components[id] != nil else {
            fatalError("[InstanceComponent] Attempting to get property of \(T.self) without creating it first.")
        }
        
        return storage.components[id]![keyPath: keyPath]
    }
    
    public func instance(for id : UUID) -> T? {
        storage.components[id]
    }
    
}

extension InstanceComponent : View {
    
    public var body: some View {
        if let id = storage.currentId, let component = storage.components[id] {
            component.view
                .onAppear {
                    Introspection.shared.updateDescriptor(forComponent: self.id) {
                        $0?.isVisible = storage.components.count > 0
                    }
                }
                .onDisappear {
                    didDestroy.send(id)
                    storage.destroy(id: id)

                    Introspection.shared.updateDescriptor(forComponent: self.id) {
                        $0?.isVisible = storage.components.count == 0
                        $0?.remove(component: id)
                    }
                }
        }
        else {
            #if DEBUG
            Text("Empty instance component view for \(String(describing: T.self))")
            #else
            EmptyView()
            #endif
        }
    }
    
}
