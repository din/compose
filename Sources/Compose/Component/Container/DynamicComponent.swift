import Foundation
import SwiftUI

protocol AnyDynamicComponent {
    
    var didCreate : SignalEmitter { get }
    var didDestroy : SignalEmitter { get }
    
}

@dynamicMemberLookup
public struct DynamicComponent<T : Component> : Component, AnyContainerComponent, AnyDynamicComponent {
    
    public let id = UUID()
    
    public let didCreate = SignalEmitter()
    public let didDestroy = SignalEmitter()
    
    public var type: Component.Type {
        T.self
    }
    
    public var observers: Void {
        None
    }
    
    public var component : T? {
        storage.component
    }
    
    public var isCreated : Bool {
        storage.component != nil
    }
    
    var containeeId: UUID {
        storage.component?.id ?? UUID()
    }
    
    let storage : DynamicComponentStorage<T>
    
    public init() {
        storage = DynamicComponentStorage<T>(lifecycleEmitterIds: [
            didCreate.id,
            didDestroy.id
        ])
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
        
        withIntrospection {
            Introspection.shared.updateDescriptor(forComponent: self.id) {
                $0?.add(component: id)
            }
            
            Introspection.shared.updateDescriptor(forComponent: id) {
                $0?.lifecycle = .dynamic
            }
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
                withIntrospection {
                    Introspection.shared.updateDescriptor(forComponent: self.id) {
                        $0?.isVisible = true
                    }
                }
            }
            .onDisappear {
                storage.destroy()
                didDestroy.send()
                
                withIntrospection {
                    Introspection.shared.updateDescriptor(forComponent: self.id) {
                        $0?.isVisible = false
                        $0?.remove(component: self.id)
                    }
                }
            }
    }
    
}
