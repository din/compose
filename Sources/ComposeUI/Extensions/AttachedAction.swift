import Foundation
import SwiftUI
import Compose

@propertyWrapper public struct AttachedAction<T> {
    
    public class ActionWrapper {
        
        var action : ((T) -> Void) = { _ in
            print("[Compose] Unhandled attached action with parameter of type \(T.self).")
        }
        
        public func perform(_ value : T) {
            action(value)
        }
        
    }
    
    public var wrappedValue : ActionWrapper {
        wrapper
    }
    
    fileprivate let wrapper = ActionWrapper()
    
    public init() {
        
    }
    
}

extension AttachedAction where T == Void {
    
    public init() {
        
    }
    
}

extension AttachedAction.ActionWrapper where T == Void {
    
    public func perform() {
        action(())
    }
    
}

extension View {
    
    public func attach<T>(_ emitter : ValueEmitter<T>, at keyPath : KeyPath<Self, AttachedAction<T>.ActionWrapper>) -> Self {
        self[keyPath: keyPath].action = { value in
            emitter.send(value)
        }
        
        return self
    }
    
    public func attach(_ emitter : SignalEmitter, at keyPath : KeyPath<Self, AttachedAction<Void>.ActionWrapper>) -> Self {
        self[keyPath: keyPath].action = { value in
            emitter.send()
        }
        
        return self
    }
    
    public func attach(_ action : AttachedAction<Void>.ActionWrapper, at keyPath : KeyPath<Self, AttachedAction<Void>.ActionWrapper>) -> Self {
        self[keyPath: keyPath].action = { value in
            action.perform(value)
        }
        
        return self
    }

    public func attach<I>(_ action : AttachedAction<I>.ActionWrapper, at keyPath : KeyPath<Self, AttachedAction<I>.ActionWrapper>) -> Self {
        self[keyPath: keyPath].action = { value in
            action.perform(value)
        }

        return self
    }
    
    public func attach<I, O>(_ action : AttachedAction<O>.ActionWrapper,
                             at keyPath : KeyPath<Self, AttachedAction<I>.ActionWrapper>,
                             transform : @escaping (I) -> O) -> Self {
        self[keyPath: keyPath].action = { value in
            action.perform(transform(value))
        }
        
        return self
    }
    
    public func attach<I, O>(_ emitter : ValueEmitter<O>,
                             at keyPath : KeyPath<Self, AttachedAction<I>.ActionWrapper>,
                             transform : @escaping (I) -> O) -> Self {
        self[keyPath: keyPath].action = { value in
            emitter.send(transform(value))
        }
        
        return self
    }
    
}

extension Button {

    public init(action : AttachedAction<Void>.ActionWrapper, @ViewBuilder label: () -> Label) {
        self.init {
            action.perform()
        } label: {
            label()
        }
    }

    public init<I>(action : AttachedAction<I>.ActionWrapper, value : I, @ViewBuilder label: () -> Label) {
        self.init {
            action.perform(value)
        } label: {
            label()
        }
    }

}
