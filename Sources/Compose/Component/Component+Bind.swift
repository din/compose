import Foundation

public protocol Bindable {
    
    func bind<C : Component>(to component : C)

}

extension Component {
    
    @discardableResult
    public func bind() -> Self {
        /* Storing lifecycle for the component in the component descriptor */
        
        withIntrospection {
            Introspection.shared.register(component: self)
        }

        /* Binding all children and wrapped values */
        
        let bindingStartTime = CFAbsoluteTimeGetCurrent()
        
        let mirror = Mirror(reflecting: self)
    
        for (name, value) in mirror.children {
            if value is Component {
                (value as? Component)?.bind()
            }
            
            withIntrospection {
                if let emitter = value as? AnyEmitter {
                    Introspection.shared.register(emitter: emitter, named: name)
                    Introspection.shared.updateDescriptor(forComponent: self.id) { descriptor in
                        descriptor?.add(emitter: emitter)
                    }
                }
                
                if let store = value as? AnyStore {
                    Introspection.shared.register(store: store, named: name)
                    Introspection.shared.updateDescriptor(forComponent: self.id) { descriptor in
                        descriptor?.add(store: store)
                    }
                }
                
                if let component = value as? Component {
                    Introspection.shared.updateDescriptor(forComponent: self.id) { descriptor in
                        descriptor?.add(component: component)
                    }
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
                        withIntrospection {
                            Introspection.shared.register(router: router, named: name)
                            
                            Introspection.shared.updateDescriptor(forComponent: self.id) {
                                $0?.add(router: router)
                            }
                        }
                    }
                }
            }
            
        }
        
        let observingStartTime = CFAbsoluteTimeGetCurrent()
        
        withIntrospection {
            Introspection.shared.pushObservationScope(id: self.id)
        }
        
        _ = self.observers
        
        for keyPath in Self.auxiliaryBindableKeyPaths {
            _ = self[keyPath: keyPath]
        }
        
        withIntrospection {
            Introspection.shared.popObservationScope(id: self.id)
            
            Introspection.shared.updateDescriptor(forComponent: self.id) {
                $0?.createdAtTime = bindingStartTime
                $0?.bindingTime = CFAbsoluteTimeGetCurrent() - bindingStartTime
                $0?.observingTime = CFAbsoluteTimeGetCurrent() - observingStartTime
            }
        }

        return self
    }

}
