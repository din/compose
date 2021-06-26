import Foundation
import SwiftUI

@propertyWrapper public struct MappedStore<Target : Component, State : AnyState> : DynamicProperty, Bindable {
    
    public var wrappedValue : State {
        container.state
    }
    
    public var projectedValue : StoreContainer<State> {
        container
    }
    
    fileprivate let keyPath : KeyPath<Target, StoreContainer<State>>
    
    @ObservedObject fileprivate var container = StoreContainer<State>()
    
    public init(for keyPath : KeyPath<Target, StoreContainer<State>>) {
        self.keyPath = keyPath
    }
    
    public func bind<C>(to component: C) where C : Component {
        guard let component = component as? Target else {
            return
        }
        
        let store = component[keyPath: keyPath]
        
        store.willChange.withCurrent() += { state in
            self.container.state = state
        }
    }
    
}
