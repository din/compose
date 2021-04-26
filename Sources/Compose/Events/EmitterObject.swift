import SwiftUI

@propertyWrapper public class EmitterObject<T> {
    
    struct Target : Hashable {
        let emitterId : UUID
        let keyPath : AnyKeyPath
    }
    
    public var wrappedValue : ValueEmitter<T> {
        guard let target = target else {
            return emptyDestinationEmitter
        }
        
        return Storage.storage(for: \EmitterObject<T>.self).value(at: target) as? ValueEmitter<T> ?? emptyDestinationEmitter
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
        
        Storage.storage(for: \EmitterObject<T>.self).setValue(emitter, at: target)
        
        return self
    }
    
}
