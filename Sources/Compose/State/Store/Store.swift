import Foundation
import SwiftUI

protocol AnyStore {
 
    var id : UUID { get }
    
    var willChange : AnyEmitter { get }
    
    var isMapped : Bool { get }
    
}

@propertyWrapper public struct Store<State : AnyState> : DynamicProperty, AnyStore {
    
    public var id : UUID {
        container.id
    }
    
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
    
    var willChange: AnyEmitter {
        container.willChange
    }
    
    var isMapped: Bool {
        false
    }
    
    @ObservedObject fileprivate var container : StoreContainer<State>

    public init(storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        container = .init(storage: storage)
    }
    
}

