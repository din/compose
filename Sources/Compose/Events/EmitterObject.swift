import SwiftUI

extension Storage {
    
    struct EmitterObjectKey<T> : Hashable {
        let target : EmitterObject<T>.Target
        let keyPath = \EmitterObject<T>.self
    }
    
}

@propertyWrapper public class EmitterObject<T> {
    
    struct Target : Hashable {
        let emitterId : UUID
        let keyPath : AnyKeyPath
    }
    
    public var wrappedValue : ValueEmitter<T> {
        guard let target = target else {
            return emptyDestinationEmitter
        }
        
        return Storage.shared.value(at: Storage.EmitterObjectKey<T>(target: target)) as? ValueEmitter<T> ?? emptyDestinationEmitter
    }
    
    public var projectedValue : EmitterObject<T> {
        self
    }
    
    let emptyDestinationEmitter = ValueEmitter<T>()
    
    var target : Target? = nil
    
    public init() {
        emptyDestinationEmitter += { _ in
            print("Unattached emitter with value type '\(T.self)' triggered from a view.")
        }
    }
    
}

extension View {
    
    public func attach<T>(emitter : ValueEmitter<T>, at keyPath : KeyPath<Self, EmitterObject<T>>) -> Self {
        let target = EmitterObject<T>.Target(emitterId: emitter.id, keyPath: keyPath)
        self[keyPath: keyPath].target = target
        
        Storage.shared.setValue(emitter, at: Storage.EmitterObjectKey<T>(target: target))
        
        return self
    }
    
}
