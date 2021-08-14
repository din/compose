import Foundation
import SwiftUI

protocol AnyDynamicComponent {
    
    var didCreate : SignalEmitter { get }
    var didDestroy : SignalEmitter { get }
    
}

@dynamicMemberLookup
public struct DynamicComponent<T : Component> : Component, AnyContainerComponent, AnyDynamicComponent {
    
    public let id = UUID()
    
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
    
    var containeeId: UUID {
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
        if let component = storage.component {
            component.view
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
        else {
            emptyBody
        }
    }
    
    private var emptyBody : some View {
        print("[DynamicComponent] Warning: component \(T.self) must be set before accessing it.")
        
        #if DEBUG
        return VStack {
            Text("Uninitialised dynamic component \(String(describing: T.self))")
                .foregroundColor(Color.orange)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
        return EmptyView()
        #endif
    }
    
}
