import Foundation
import SwiftUI

@propertyWrapper public struct StaticStore<State : AnyState> {
    
    public var wrappedValue : State {
        get {
            container.state
        }
        nonmutating set {
            container.state = newValue
        }
    }
    
    public var projectedValue : BackingStore<State> {
        container
    }
    
    fileprivate var container : BackingStore<State>
    
    public init(storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        container = .init(storage: storage)
    }
    
}
