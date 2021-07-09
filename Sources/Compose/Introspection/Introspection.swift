import Foundation
import Combine

public class Introspection {
    
    ///Shared introspection instnace.
    static let shared = Introspection()
    
    ///Whether the introspection as a whole is enabled or not.
    ///Introspection can only be enabled in DEBUG builds.
    fileprivate var isEnabled = false
    
    ///Client to send changes to.
    fileprivate var client : IntrospectionClient? = nil
    
    ///Startup component identifier.
    fileprivate var startupComponentId : UUID = UUID()
    
    ///All components registered for the introspection.
    @Published fileprivate var componentDescriptors = [UUID : ComponentDescriptor]()
        
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
        
        $componentDescriptors
            .receive(on: DispatchQueue.global())
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [unowned self] _ in
                do {
                    let descriptor = AppDescriptor(name: Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Untitled App",
                                                   startupComponentId: self.startupComponentId,
                                                   components: self.componentDescriptors)
                    
                    try client?.send(descriptor)
                }
                catch let error {
                    print("[Introspection] Error advertising introspection changes: \(error)")
                }
            }
            .store(in: &cancellables)
    }
    
}

extension Introspection {
    
    ///Registers a component with the introspection.
    func register(_ component : Component) {
        var lifecycle : ComponentDescriptor.Lifecycle = .static
        
        switch component {
        
        case is AnyDynamicComponent:
            lifecycle = .dynamic
            
        case is AnyInstanceComponent:
            lifecycle = .instance
            
        default:
            break
            
        }
        
        componentDescriptors[component.id] = ComponentDescriptor(id: component.id,
                                                                 lifecycle: lifecycle,
                                                                 name: String(describing: component.type))
        
        if component is StartupComponent {
            startupComponentId = component.id
        }
    }
    
    ///Unregisters a component and removes it from the introspection.
    func unregister(_ id : UUID) {
        guard let descriptor = componentDescriptors[id] else {
            return
        }
        
        let enumerator = descriptor.routers.objectEnumerator()
        
        while let router = enumerator?.nextObject() as? Router {
            router.target = nil
            router.routes.removeAll()
        
            ObservationBag.shared.remove(for: router.didPush.id)
            ObservationBag.shared.remove(for: router.didPop.id)
            ObservationBag.shared.remove(for: router.didReplace.id)
        }
    }
    
}

extension Introspection {
    
    func updateDescriptor(for component : Component, update : (inout ComponentDescriptor?) -> Void) {
        update(&componentDescriptors[component.id])
    }
    
    func updateDescriptor(for id : UUID, update : (inout ComponentDescriptor?) -> Void) {
        update(&componentDescriptors[id])
    }
    
    func descriptor(for id : UUID) -> ComponentDescriptor? {
        componentDescriptors[id]
    }
    
}
