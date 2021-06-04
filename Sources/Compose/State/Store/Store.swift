import Foundation
import SwiftUI

@propertyWrapper public struct Store<State : AnyState> : DynamicProperty {
    
    public var wrappedValue : State {
        get {
            container.state
        }
        nonmutating set {
            container.state = newValue
        }
    }
    
    public var projectedValue : StoreContainer<State> {
        container
    }
    
    @ObservedObject fileprivate var container : StoreContainer<State>

    public init(storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        container = .init(storage: storage)
    }
    
}
