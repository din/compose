import Foundation
import Combine

@inlinable
func withIntrospection(_ action : () -> Void) {
    #if DEBUG
    if Introspection.shared.isEnabled == true {
        action()
    }
    #endif
}

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
    
    ///Queue to operate on.
    fileprivate var queue : OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
     
    ///App descriptor.
    let app = AppDescriptor()
    
    ///Observation scope contrext.
    fileprivate var observationScopeIds = [UUID]()
    
    ///Services ids.
    fileprivate var servicesIds = [ObjectIdentifier : UUID]()
    
    ///Managing cancellables in here.
    fileprivate var cancellables = Set<AnyCancellable>()
    
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
                
                self.advertiseAppDescriptor()
            }
            .store(in: &cancellables)
        
        app.objectWillChange
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.global())
            .sink { [unowned self] _ in                
                self.advertiseAppDescriptor()
            }
            .store(in: &cancellables)
    }
    
    fileprivate func advertiseAppDescriptor() {
        queue.addOperation { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                try self.client?.send(self.app)
            }
            catch let error {
                print("[Compose] Error advertising introspection changes: \(error)")
            }
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
        
        app.components[component.id] = ComponentDescriptor(id: component.id,
                                                                name: String(describing: component.type),
                                                                lifecycle: lifecycle)
        
        if component is StartupComponent {
            app.startupComponentId = component.id
        }
    }
    
    ///Unregisters a component and removes it from the introspection.
    func unregister(component id : UUID) {
        guard let descriptor = app.components[id] else {
            return
        }
        
        descriptor.emitters.forEach {
            unregister(emitter: $0)
        }
    }

    func updateDescriptor(forComponent id : UUID, update : (inout ComponentDescriptor?) -> Void) {
        update(&app.components[id])
    }
    
    func descriptor(forComponent id : UUID) -> ComponentDescriptor? {
        app.components[id]
    }
    
}

extension Introspection {
    
    func register(emitter : AnyEmitter, named name : String?) {
        app.emitters[emitter.id] = EmitterDescriptor(id: emitter.id,
                                                     name: name ?? "Unnamed",
                                                     description: emitter.debugDescription,
                                                     valueDescription: "")
    }
    
    func unregister(emitter id : UUID) {
        guard let descriptor = app.emitters[id] else {
            return
        }
        
        app.emitters[id] = nil
        
        descriptor.observers.forEach {
            unregister(observer: $0)
        }
    }
    
    func updateDescriptor(forEmitter id : UUID, update : (inout EmitterDescriptor?) -> Void) {
        update(&app.emitters[id])
    }
    
}

extension Introspection {
    
    func register<O : Observer<E, V>, E : Emitter, V>(observer : O,
                                                      emitterId : UUID) {
        app.observers[observer.id] = ObserverDescriptor(id: observer.id,
                                                        description: String(describing: E.self),
                                                        emitterId: emitterId)
    }
    
    func unregister(observer id : UUID) {
        if let observer = app.observers[id] {
            updateDescriptor(forEmitter: observer.emitterId) {
                $0?.observers.remove(id)
            }
            
            if let componentId = observer.componentId {
                updateDescriptor(forComponent: componentId) {
                    $0?.observers.remove(id)
                }
            }
        }
        
        app.observers[id] = nil
    }
 
    func updateDescriptor(forObserver id : UUID, update : (inout ObserverDescriptor?) -> Void) {
        update(&app.observers[id])
    }
    
    func descriptor(forObserver id : UUID) -> ObserverDescriptor? {
        app.observers[id]
    }
    
    func pushObservationScope(id : UUID) {
        observationScopeIds.append(id)
    }
    
    func popObservationScope() {
        observationScopeIds.removeLast()
    }
    
    var observationScopeId : UUID {
        observationScopeIds.last ?? UUID()
    }
    
}

extension Introspection {
    
    func register(store : AnyStore, named name : String?) {
        app.stores[store.id] = StoreDescriptor(id: store.id,
                                               name: name ?? "Unknown",
                                               isMapped: store.isMapped)
    }
    
    func updateDescriptor(forStore id : UUID, update : (inout StoreDescriptor?) -> Void) {
        update(&app.stores[id])
    }
    
}

extension Introspection {
    
    func register(router : Router, named name : String?) {
        guard app.routers[router.id] == nil else {
            return
        }
        
        app.routers[router.id] = RouterDescriptor(id: router.id,
                                                            name: name ?? "Unknown",
                                                            hasDefaultContent: router.start == nil)
        
        app.routers[router.id]?.routes = router.routes.map { $0.id }
    }
    
    func updateDescriptor(forRouter id : UUID, update : (inout RouterDescriptor?) -> Void) {
        update(&app.routers[id])
    }
    
}

extension Introspection {
    
    func register<S : Service>(service : S) {
        var id = UUID()
        
        if let existingId = servicesIds[ObjectIdentifier(S.self)] {
            id = existingId
        }
        else {
            servicesIds[ObjectIdentifier(S.self)] = id
        }
        
        var descriptor = ComponentDescriptor(id: id,
                                             name: String(describing: S.self),
                                             lifecycle: .service)
        
        let mirror = Mirror(reflecting: service)
        
        for (name, value) in mirror.children {
            
            if let emitter = value as? AnyEmitter {
                Introspection.shared.register(emitter: emitter, named: name)

                descriptor.add(emitter: emitter)
            }
            
            if let store = value as? AnyStore {
                let name = name?.replacingOccurrences(of: "_", with: "") ?? "state"
                
                Introspection.shared.register(store: store, named: name)
                
                descriptor.add(store: store)
        
                Introspection.shared.register(emitter: store.willChange, named: "\(name).willChange")
                
                Introspection.shared.updateDescriptor(forEmitter: store.willChange.id) {
                    $0?.componentId = id
                }
            }
            
        }
        
        app.components[id] = descriptor
    }
    
}
