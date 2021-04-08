import Foundation
import SwiftUI

@dynamicMemberLookup
public struct LazyComponent<T : Component> : Component {
    
    let storage = ComponentStorage<T>()
    let allocator : () -> T
    
    public let created = SignalEmitter()
    public let viewAppeared = SignalEmitter()
    public let viewDisappeared = SignalEmitter()
    
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
            storage.component = allocator().bind()
            created.send()
        }
        
        return storage.component?.view
            .onAppear {
                self.viewAppeared.send()
            }
            .onDisappear {
                self.storage.component = nil
                self.viewDisappeared.send()
            }
    }
    
}
