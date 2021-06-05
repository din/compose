import SwiftUI

extension Storage {
    
    struct AttachedEmitterKey<T> : Hashable {
        let target : AttachedEmitter<T>.Target
        let keyPath = \AttachedEmitter<T>.self
    }
    
}

@propertyWrapper public class AttachedEmitter<T> {
    
    struct Target : Hashable {
        let emitterId : UUID
        let keyPath : AnyKeyPath
    }
    
    public var wrappedValue : ValueEmitter<T> {
        guard let target = target else {
            return emptyDestinationEmitter
        }
        
        return Storage.shared.value(at: Storage.AttachedEmitterKey<T>(target: target)) as? ValueEmitter<T> ?? emptyDestinationEmitter
    }
    
    public var projectedValue : AttachedEmitter<T> {
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
    
    public func attach<T>(emitter : ValueEmitter<T>, at keyPath : KeyPath<Self, AttachedEmitter<T>>) -> Self {
        let target = AttachedEmitter<T>.Target(emitterId: emitter.id, keyPath: keyPath)
        self[keyPath: keyPath].target = target
        
        Storage.shared.setValue(emitter, at: Storage.AttachedEmitterKey<T>(target: target))
        
        return self
    }
    
}
