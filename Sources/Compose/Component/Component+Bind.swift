import Foundation
import UIKit
import SwiftUI
import Combine

extension Component {
    
    @discardableResult
    func bind() -> ComponentController {
        let controller = ComponentController(component: self)
        
        /* Intrinsic emitters */
        
        var intrinsicEmitters : [AnyEmitter] = [
            controller.didCreate,
            controller.didDestroy,
            controller.didAppear,
            controller.didDisappear
        ]
        
        if let component = self as? AnyDynamicComponent {
            intrinsicEmitters.append(contentsOf: [
                component.didCreateInstance,
                component.didDestroyInstance
            ])
        }
        
        intrinsicEmitters.forEach {
            ComponentControllerStorage.shared.ownedEntities[$0.id] = controller.id
        }
        
        /* Bindables */
        
        let mirror = Mirror(reflecting: self)
        
        for (name, value) in mirror.children {
            // Registering subcomponents
            if let subcomponent = value as? Component {
                controller.addChildController(subcomponent.bind())
            }
            
            // Registering component entries
            if let value = value as? ComponentEntry {
                ComponentControllerStorage.shared.ownedEntities[value.id] = controller.id
                ComponentControllerStorage.shared.displayNamesOfEntities[value.id] = name
                value.didBind()
            }
            
            // Registering stores
            if let store = value as? AnyStore {
                ComponentControllerStorage.shared.ownedEntities[store.willChange.id] = controller.id
            }
            
            // Registering component entries inside dictionaries
            if let entries = value as? Dictionary<AnyHashable, ComponentEntry> {
                entries.values.forEach {
                    ComponentControllerStorage.shared.ownedEntities[$0.id] = controller.id
                }
            }
            
            if let name = name, name.hasPrefix("_") {
                let wrapperMirror = Mirror(reflecting: value)

                for (_, wrappedValue) in wrapperMirror.children {
                    // Registering nested component entries
                    if let wrappedValue = wrappedValue as? ComponentEntry {
                        ComponentControllerStorage.shared.ownedEntities[wrappedValue.id] = controller.id
                        ComponentControllerStorage.shared.displayNamesOfEntities[wrappedValue.id] = name
                        wrappedValue.didBind()
                    }
                }
            }
        }
        
        /* Observers */
        
        ComponentControllerStorage.shared.pushEventScope(for: id)
 
        _ = self.observers
        
        for keyPath in ComponentAuxiliaryBindableKeyPaths {
            _ = self[keyPath: keyPath]
        }
        
        ComponentControllerStorage.shared.popEventScope()
   
        return controller
    }
    
}

extension Component {
    
    public func withComponentScope(action : () -> Void) {
        ComponentControllerStorage.shared.pushEventScope(for: self.id)
        
        action()
        
        ComponentControllerStorage.shared.popEventScope()
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
