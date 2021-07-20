import Foundation
import Combine

public class Introspection : ObservableObject {
    
    ///Shared introspection instnace.
    static let shared = Introspection()
    
    ///Whether the introspection as a whole is enabled or not.
    ///Introspection can only be enabled in DEBUG builds.
    fileprivate(set) var isEnabled = false
    
    ///Client to send changes to.
    fileprivate var client : IntrospectionClient? = nil
    
    ///Startup component identifier.
    fileprivate var startupComponentId : UUID = UUID()
    
    ///All components registered for the introspection.
    fileprivate var componentDescriptors = [UUID : ComponentDescriptor]() {
        
        didSet {
            objectWillChange.send()
        }
        
    }

    ///Emitter descriptors.
    fileprivate var emitterDescriptors = [UUID : EmitterDescriptor]() {
        
        didSet {
            objectWillChange.send()
        }
        
    }
    
    ///Observer descriptors.
    fileprivate var observerDescriptors = [UUID : ObserverDescriptor]() {
        
        didSet {
            objectWillChange.send()
        }
        
    }
    
    ///Managing cancellables in here.
    fileprivate var cancellables = Set<AnyCancellable>()
    
}

extension Introspection {
    
    ///Enables introspection for the whole app.
    ///Works ony for builds made in DEBUG mode.
    public static func enable() {
        #if DEBUG
        shared.isEnabled = true
        #endif
        
        shared.advertise()
    }
    
    ///Launchs the client to  advertise changes to the app.
    fileprivate func advertise() {
        client = IntrospectionClient()
        
        client?.$connectionState
            .sink { [unowned self] state in
                guard state == .connected else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.advertiseAppDescriptor()
                }
            }
            .store(in: &cancellables)
        
        objectWillChange
            .receive(on: DispatchQueue.global())
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.global())
            .sink { [unowned self] _ in
                print("[Introspection] Advertising data")
                
                self.advertiseAppDescriptor()
            }
            .store(in: &cancellables)
    }
    
    fileprivate func advertiseAppDescriptor() {
        do {
            let descriptor = AppDescriptor(name: Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Untitled App",
                                           startupComponentId: self.startupComponentId,
                                           components: self.componentDescriptors,
                                           emitters: self.emitterDescriptors)
            
            try client?.send(descriptor)
        }
        catch let error {
            print("[Introspection] Error advertising introspection changes: \(error)")
        }
    }
    
}

extension Introspection {
    
    ///Registers a component with the introspection.
    func register(component : Component) {
        var lifecycle : ComponentDescriptor.Lifecycle = .static
        
        switch component {
        
        case is AnyContainerComponent:
            lifecycle = .container
            
        default:
            break
            
        }
        
        componentDescriptors[component.id] = ComponentDescriptor(id: component.id,
                                                                 name: String(describing: component.type),
                                                                 lifecycle: lifecycle)
        
        if component is StartupComponent {
            startupComponentId = component.id
        }
    }
    
    ///Unregisters a component and removes it from the introspection.
    func unregister(component id : UUID) {
        guard let descriptor = componentDescriptors[id] else {
            return
        }
        
        let enumerator = descriptor.runtimeRouterObjects.objectEnumerator()
        
        while let router = enumerator?.nextObject() as? Router {
            router.target = nil
            router.routes.removeAll()
        
            ObservationBag.shared.remove(for: router.didPush.id)
            ObservationBag.shared.remove(for: router.didPop.id)
            ObservationBag.shared.remove(for: router.didReplace.id)
        }
        
        descriptor.emitters.values.forEach {
            unregister(emitter: $0)
        }
    }
    
    func updateDescriptor(forComponent component : Component, update : (inout ComponentDescriptor?) -> Void) {
        update(&componentDescriptors[component.id])
    }
    
    func updateDescriptor(forComponent id : UUID, update : (inout ComponentDescriptor?) -> Void) {
        update(&componentDescriptors[id])
    }
    
    func descriptor(forComponent id : UUID) -> ComponentDescriptor? {
        componentDescriptors[id]
    }
    
}

extension Introspection {
    
    func register<E : Emitter>(emitter : E) {
        emitterDescriptors[emitter.id] = EmitterDescriptor(id: emitter.id,
                                                           description: String(describing: E.Value.self),
                                                           valueDescription: "")
    }
    
    func unregister(emitter id : UUID) {
        emitterDescriptors[id] = nil
    }
    
    func updateDescriptor(forEmitter emitter : AnyEmitter, update : (inout EmitterDescriptor?) -> Void) {
        update(&emitterDescriptors[emitter.id])
    }
    
}

extension Introspection {
    
    func register(observer : AnyObserver) {
        observerDescriptors[observer.id] = ObserverDescriptor(componentId: <#T##UUID?#>, modifiers: <#T##[String]#>)
    }
    
    func unregister(observer id : UUID) {
        
    }
    
}
