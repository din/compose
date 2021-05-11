import Foundation

extension Component {

    @discardableResult
    public func bind() -> Self {
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
                
                for (_, value) in wrapperMirror.children {
                    if let value = value as? Bindable {
                        value.bind(to: self)
                    }
                }
            }
            
        }

        _ = self.observers
 
        return self
    }
    
}
