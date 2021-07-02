import Foundation
import SwiftUI

@dynamicMemberLookup
public struct DynamicComponent<T : Component> : Component {
    
    let storage = DynamicComponentStorage<T>()
    
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
    
    func destroy() {
        storage.destroy()
    }
}

extension DynamicComponent {
    
    public func create(_ allocator : () -> T) {
        guard isCreated == false else {
            print("[DynamicComponent] Warning: trying to create component \(T.self) more than one time")
            return
        }
        
        storage.create(allocator: allocator)
        didCreate.send()
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
            .onDisappear {
                storage.destroy()
                didDestroy.send()
            }
    }
    
}
