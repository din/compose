import Foundation

extension Component {
    
    @discardableResult
    public func bind() -> Self {
        var result = BindingResult()
        return bind(&result)
    }

    func bind(_ result : inout BindingResult) -> Self {
        /* Binding all children and wrapped values */
        
        let mirror = Mirror(reflecting: self)
    
        for (name, value) in mirror.children {
            if value is Component {
                (value as? Component)?.bind()
            }
            
            if let value = value as? Bindable {
                value.bind(to: self)
            }
            
            /* Binding bindables */

            if let name = name, name.hasPrefix("_") {
                let wrapperMirror = Mirror(reflecting: value)
                
                for (_, wrappedValue) in wrapperMirror.children {
                    if let wrappedValue = wrappedValue as? Bindable {
                        wrappedValue.bind(to: self)

                    }
                    
                    //Storing class-based bindables
                    if let wrappedValue = wrappedValue as? BindableObject {
                        result.bindableObjects.addPointer(Unmanaged.passUnretained(wrappedValue as AnyObject).toOpaque())
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
