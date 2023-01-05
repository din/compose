import Foundation
import UIKit
import SwiftUI
import Combine

extension Component {
    
    @discardableResult
    func bind() -> ComponentController {
        let controller = ComponentController(component: self)
        
        /* Bindables */
        
        let mirror = Mirror(reflecting: self)
        
        for (name, value) in mirror.children {
            // Registering subcomponents
            if let subcomponent = value as? Component {
                controller.addChildController(subcomponent.bind())
            }
            
            if let value = value as? ComponentEntry {
                ComponentControllerStorage.shared.ownedEntities[value.id] = controller.id
            }
            
            if let name = name, name.hasPrefix("_") {
                let wrapperMirror = Mirror(reflecting: value)
                
                for (_, wrappedValue) in wrapperMirror.children {
                    if let wrappedValue = wrappedValue as? ComponentEntry {
                        ComponentControllerStorage.shared.ownedEntities[wrappedValue.id] = controller.id
                    }
                }
            }
        }
        
        /* Observers */
 
        _ = self.observers
        
        for keyPath in Self.auxiliaryBindableKeyPaths {
            _ = self[keyPath: keyPath]
        }
   
        return controller
    }
    
}

extension Component {
    
    var controller : ComponentController {
        guard let controller = ComponentControllerStorage.shared.controllers[self.id] else {
            print("[CCC] Warning: no associated controller for the component '\(type(of: self))' found.")
            return ComponentController(component: TransientComponent(content: EmptyView()))
        }
        
        return controller
    }
    
}
