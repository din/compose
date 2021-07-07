import Foundation
import SwiftUI

protocol AnyDynamicComponent {
    
}

@dynamicMemberLookup
public struct DynamicComponent<T : Component> : Component, AnyDynamicComponent {
    
    let storage = DynamicComponentStorage<T>()
    
    public var type: Component.Type {
        T.self
    }
    
    public var observers: Void {
        None
    }
    
    public var didCreate : SignalEmitter {
        storage.didCreate
    }
    
    public var didDestroy : SignalEmitter {
        storage.didDestroy
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
        guard isCreated == false else {
            print("[DynamicComponent] Warning: trying to create component \(T.self) more than one time")
            return
        }
        
        let id = storage.create(allocator: allocator)
        didCreate.send()
        
        Introspection.shared.updateDescriptor(for: self) {
            $0?.add(component: id)
        }
    }
    
    public subscript<V>(dynamicMember keyPath : KeyPath<T, V>) -> V {
        guard storage.component != nil else {
            fatalError("[DynamicComponent] Attempting to get property of \(T.self) without creating it first.")
        }
        
        return storage.component![keyPath: keyPath]
    }
    
}

extension DynamicComponent : View {
    
    public var body: some View {
        guard let component = storage.component else {
            fatalError("[DynamicComponent] Component \(T.self) must be set before accessing it.")
        }
        
        return component.view
            .onAppear {
                Introspection.shared.updateDescriptor(for: self) {
                    $0?.isVisible = true
                }
            }
            .onDisappear {
                storage.destroy()
                didDestroy.send()
                
                Introspection.shared.updateDescriptor(for: self) {
                    $0?.isVisible = false
                    $0?.remove(component: id)
                }
            }
    }
    
}
