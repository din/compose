import Foundation
import SwiftUI

@dynamicMemberLookup
public struct DynamicComponent<T : Component> : Component {
    
    let storage = ComponentStorage<T>()
    
    public let destroyOnDisappearance : Bool
    
    public init(destroyOnDisappearance : Bool) {
        self.destroyOnDisappearance = destroyOnDisappearance
    }
    
    public init() {
        self.destroyOnDisappearance = false
    }
    
}

extension DynamicComponent {
    
    @discardableResult
    public func create(_ allocator : () -> T) -> T {
        let component = allocator().bind()
        storage.component = component
        return component
    }
    
    public func destroy() {
        storage.component = nil
    }
    
    public subscript<V>(dynamicMember keyPath : KeyPath<T, V>) -> V {
        guard storage.component != nil else {
            fatalError("Attempting to get dynamic component's property without creating it first.")
        }
        
        return storage.component![keyPath: keyPath]
    }
    
}

extension DynamicComponent : View {
    
    public var body: some View {
        guard let component = storage.component else {
            fatalError("DynamicComponent's component must be set before accessing it.")
        }
        
        return component.view
            .onDisappear {
                guard destroyOnDisappearance == true else {
                    return
                }
                
                self.storage.component = nil
            }
    }
    
}
