import Foundation

public protocol Bindable {
    
    func bind<C : Component>(to component : C)

}

extension Component {
    
    @discardableResult
    public func bind() -> Self {
        /* Storing lifecycle for the component in the component descriptor */
        
        Introspection.shared.register(self)

        /* Binding all children and wrapped values */
        
        let bindingStartTime = CFAbsoluteTimeGetCurrent()
        
        let mirror = Mirror(reflecting: self)
    
        for (name, value) in mirror.children {
            if value is Component {
                (value as? Component)?.bind()
            }
            
             if let name = name {
                Introspection.shared.updateDescriptor(for: self) {
                    $0?.add(component: value as? Component, for: name)
                    $0?.add(emitter: value as? AnyEmitter, for: name)
                    $0?.add(store: value as? AnyStore, for: name)
                }
            }
            
            /* Binding bindables */
            
            if let value = value as? Bindable {
                value.bind(to: self)
            }

            if let name = name, name.hasPrefix("_") {
                let wrapperMirror = Mirror(reflecting: value)
                
                for (_, wrappedValue) in wrapperMirror.children {
                    if let wrappedValue = wrappedValue as? Bindable {
                        wrappedValue.bind(to: self)
                    }
                    
                    if let router = wrappedValue as? Router {
                        Introspection.shared.updateDescriptor(for: self) {
                            $0?.add(router: router, for: name)
                        }
                    }
                }
            }
            
        }
        
        let observingStartTime = CFAbsoluteTimeGetCurrent()

        _ = self.observers
        
        for keyPath in Self.auxiliaryBindableKeyPaths {
            _ = self[keyPath: keyPath]
        }
     
        Introspection.shared.updateDescriptor(for: self) {
            $0?.createdAtTime = bindingStartTime
            $0?.bindingTime = CFAbsoluteTimeGetCurrent() - bindingStartTime
            $0?.observingTime = CFAbsoluteTimeGetCurrent() - observingStartTime
            
            //TODO: refactor observers gathering.
            let observers = $0?.emitters.values.compactMap { ObservationBag.shared.cancellables[$0] }.flatMap { $0 } ?? []
            $0?.observers = observers.map { _ in UUID() }
        }
        
        return self
    }
    
}
