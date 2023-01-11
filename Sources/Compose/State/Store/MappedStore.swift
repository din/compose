import Foundation
import SwiftUI

@propertyWrapper public struct MappedStore<Target : Component, State : AnyState> : DynamicProperty, ComponentEntry, AnyStore {
    
    public var id : UUID {
        container.id
    }
    
    public var wrappedValue : State {
        container.state
    }
    
    public var projectedValue : StoreContainer<State> {
        container
    }
    
    var willChange: AnyEmitter {
        container.willChange
    }
    
    var isMapped: Bool {
        true
    }
    
    fileprivate let keyPath : KeyPath<Target, StoreContainer<State>>
    
    @ObservedObject fileprivate var container = StoreContainer<State>()
    
    public init(for keyPath : KeyPath<Target, StoreContainer<State>>) {
        self.keyPath = keyPath
    }
    
    public func didBind() {
        guard let controller = ComponentControllerStorage.shared.owner(for: self.id) else {
            return
        }
        
        guard let component = controller.component as? Target else {
            return
        }
        
        ComponentControllerStorage.shared.pushEventScope(for: component.id)
        
        component[keyPath: keyPath].willChange.withCurrent() += { state in
            self.container.state = state
        }
        
        ComponentControllerStorage.shared.popEventScope()
    }
    
}
