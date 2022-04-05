import Foundation

#if os(iOS)
import UIKit
#endif

public protocol Bindable {
    
    func bind<C : Component>(to component : C)

}

extension Component {
    
    @discardableResult
    public func bind() -> Self {
        /* Storing lifecycle for the component in the component descriptor */
        
        let node = ObservationTree.shared.currentNode?.addChild(id: self.id)
        
        ObservationTree.shared.push(id: self.id)
        
        node?.addChild(id: didAppear.id)
        node?.addChild(id: didDisappear.id)
        
        withIntrospection {
            Introspection.shared.register(component: self)
            
            var emitters = [String : AnyEmitter]()
            
            emitters["didAppear"] = self.didAppear
            emitters["didDisappear"] = self.didDisappear
            
            if let component = self as? AnyDynamicComponent {
                emitters["didCreate"] = component.didCreate
                emitters["didDestroy"] = component.didDestroy
            }
            else if let component = self as? AnyInstanceComponent {
                emitters["didCreate"] = component.didCreate
                emitters["didDestroy"] = component.didDestroy
            }
            
            emitters.forEach {
                Introspection.shared.register(emitter: $0.value, named: $0.key)
                
                Introspection.shared.updateDescriptor(forEmitter: $0.value.id ) {
                    $0?.componentId = self.id
                    $0?.isLifecycle = true
                }
            }
            
            Introspection.shared.updateDescriptor(forComponent: self.id) { descriptor in
                emitters.forEach {
                    descriptor?.add(emitter: $0.value)
                }
            }
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
                    let name = name?.replacingOccurrences(of: "_", with: "") ?? "state"
                    
                    Introspection.shared.register(store: store, named: name)
                    Introspection.shared.updateDescriptor(forComponent: self.id) { descriptor in
                        descriptor?.add(store: store)
                    }
                    
                    Introspection.shared.register(emitter: store.willChange, named: "\(name).willChange")
                    
                    Introspection.shared.updateDescriptor(forEmitter: store.willChange.id) {
                        $0?.componentId = id
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
            Introspection.shared.popObservationScope()
            
            Introspection.shared.updateDescriptor(forComponent: self.id) {
                $0?.createdAtTime = bindingStartTime
                $0?.bindingTime = CFAbsoluteTimeGetCurrent() - bindingStartTime
                $0?.observingTime = CFAbsoluteTimeGetCurrent() - observingStartTime
            }
        }
        
        ObservationTree.shared.pop()

        return self
    }

}
