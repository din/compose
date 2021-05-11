import Foundation
import SwiftUI

@dynamicMemberLookup
public struct LazyComponent<T : Component> : Component {
    
    let storage = DynamicComponentStorage<T>()
    let allocator : () -> T
    
    public let didCreate = SignalEmitter()
    public let didAppear = SignalEmitter()
    public let didDisappear = SignalEmitter()
    
    public var observers: Void {
        None
    }
    
    public var isCreated : Bool {
        storage.isCreated
    }
    
    public init(_ allocator : @autoclosure @escaping () -> T) {
        self.allocator = allocator
    }
    
}

extension LazyComponent {
    
    public subscript<V>(dynamicMember keyPath : KeyPath<T, V>) -> V {
        guard storage.component != nil else {
            fatalError("Attempting to get lazy component's property without creating it first.")
        }
        
        return storage.component![keyPath: keyPath]
    }
    
}

extension LazyComponent : View {
    
    public var body: some View {
        if storage.component == nil {
            storage.create(allocator: allocator)
            didCreate.send()
        }
        
        return storage.component?.view
            .onAppear {
                self.didAppear.send()
            }
            .onDisappear {
                storage.destroy()
                self.didDisappear.send()
            }
    }
    
}
