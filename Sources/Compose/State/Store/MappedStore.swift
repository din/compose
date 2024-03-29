import Foundation
import SwiftUI

@propertyWrapper public struct MappedStore<Target : Component, State : AnyState> : DynamicProperty, Bindable, AnyStore {
    
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
