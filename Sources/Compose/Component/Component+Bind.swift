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
        
        let mirror = Mirror(reflecting: self)
    
        for (name, value) in mirror.children {
            if value is Component {
                (value as? Component)?.bind()
            }
            
            /* if let name = name, let component = value as? Component {
                Introspection.shared.updateDescriptor(for: self) {
                    $0?.add(component: component, for: name)
                }
            }*/
            
            /*if let name = name, let emitter = value as? AnyEmitter {
                Introspection.shared.updateDescriptor(for: self) {
                    $0?.add(emitter: emitter, for: name)
                }
            }*/
            
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

        _ = self.observers
        
        for keyPath in Self.auxiliaryBindableKeyPaths {
            _ = self[keyPath: keyPath]
        }
     
        return self
    }
    
}
