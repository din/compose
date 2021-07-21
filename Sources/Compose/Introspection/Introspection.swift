import Foundation
import Combine

public class Introspection {
    
    ///Shared introspection instnace.
    public static let shared = Introspection()
    
    ///Whether the introspection as a whole is enabled or not.
    ///Introspection can only be enabled in DEBUG builds.
    #if DEBUG
    public var isEnabled = false {
        
        didSet {
            if isEnabled == true {
                advertise()
            }
        }
        
    }
    #else
    public let isEnabled = false
    #endif
    
    ///Whether component allocation/deallocation tracking is enabled or disabled.
    ///When enabled, all component logs are printed out in Xcode.
    #if DEBUG
    public var isComponentAllocationTrackingEnabled = false
    #else
    public let isComponentAllocationTrackingEnabled = false
    #endif
    
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
    
    ///Sending out events.
    let objectWillChange = PassthroughSubject<Void, Never>()
    
}

extension Introspection {
    
    ///Launchs the client to  advertise changes to the app.
    fileprivate func advertise() {
        guard client == nil else {
            return
        }
        
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
            print("[Compose] Error advertising introspection changes: \(error)")
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
        guard let descriptor = emitterDescriptors[id] else {
            return
        }
        
        emitterDescriptors[id] = nil
        
        descriptor.observers.forEach {
            unregister(observer: $0.id)
        }
    }
    
    func updateDescriptor(forEmitter emitter : AnyEmitter, update : (inout EmitterDescriptor?) -> Void) {
        update(&emitterDescriptors[emitter.id])
    }
    
}

extension Introspection {
    
    func register(observer : AnyObserver, for componentId : UUID) {
        observerDescriptors[observer.id] = ObserverDescriptor(id: UUID(),
                                                              componentId: componentId,
                                                              modifiers: [])
    }
    
    func unregister(observer id : UUID) {
        observerDescriptors[id] = nil
    }
    
}
