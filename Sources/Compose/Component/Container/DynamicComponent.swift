import Foundation
import SwiftUI

protocol AnyDynamicComponent {
    //This protocol is intentionally left blank.
}

@dynamicMemberLookup
public struct DynamicComponent<T : Component> : Component, AnyContainerComponent, AnyDynamicComponent {
    
    public let id = UUID()
    
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

    public var containeeId: UUID {
        storage.component?.id ?? UUID()
    }
    
    let storage = DynamicComponentStorage<T>()
    
    public init() {
        // Intentionally left blank
    }

}

extension DynamicComponent {
    
    public func create(_ allocator : () -> T) {
        guard isCreated == false else {
            print("[Compose] Warning: trying to create dynamic component \(T.self) more than one time")
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
            fatalError("[Compose] Attempting to get property of dynamic component \(T.self) without creating it first.")
        }
        
        return storage.component![keyPath: keyPath]
    }
    
}

extension DynamicComponent : View {
    
    public var body: some View {
        guard let component = storage.component else {
            fatalError("[Compose] Dynamic component \(T.self) must be set before accessing it.")
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
                let id = storage.destroy()
                didDestroy.send()
                
                withIntrospection {
                    Introspection.shared.updateDescriptor(forComponent: self.id) {
                        $0?.isVisible = false
                        
                        if let id = id {
                            $0?.remove(component: id)
                        }
                    }
                }
            }
    }
    
}
