import Foundation
import SwiftUI

protocol AnyStore {
 
    var id : UUID { get }
    
}

@propertyWrapper public struct Store<State : AnyState> : DynamicProperty, AnyStore {
    
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
    
    public let id = UUID()
    
    @ObservedObject fileprivate var container : StoreContainer<State>

    public init(storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        container = .init(storage: storage)
    }
    
}
