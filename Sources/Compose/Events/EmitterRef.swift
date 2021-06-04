import SwiftUI

extension Storage {
    
    struct EmitterRefKey<T> : Hashable {
        let target : EmitterRef<T>.Target
        let keyPath = \EmitterRef<T>.self
    }
    
}

@propertyWrapper public class EmitterRef<T> {
    
    struct Target : Hashable {
        let emitterId : UUID
        let keyPath : AnyKeyPath
    }
    
    public var wrappedValue : ValueEmitter<T> {
        guard let target = target else {
            return emptyDestinationEmitter
        }
        
        return Storage.shared.value(at: Storage.EmitterRefKey<T>(target: target)) as? ValueEmitter<T> ?? emptyDestinationEmitter
    }
    
    public var projectedValue : EmitterRef<T> {
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
    
    public func attach<T>(emitter : ValueEmitter<T>, at keyPath : KeyPath<Self, EmitterRef<T>>) -> Self {
        let target = EmitterRef<T>.Target(emitterId: emitter.id, keyPath: keyPath)
        self[keyPath: keyPath].target = target
        
        Storage.shared.setValue(emitter, at: Storage.EmitterRefKey<T>(target: target))
        
        return self
    }
    
}
