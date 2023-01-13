import Foundation
import SwiftUI
import UIKit
import Combine

class ComponentControllerStorage {
    
    static let shared = ComponentControllerStorage()
    
    // All controllers in the app.
    var controllers = WeakDictionary<UUID, ComponentController>()
    
    // All owned entries. Key is the entry ID, value is the ID of controller which owns the entity.
    var ownedEntities = [UUID : UUID]()
    
    // Entities display names.
    var displayNamesOfEntities = [UUID : String]()
    
    // Environment values per component.
    var environmentValues = [UUID : EnvironmentValues]()
    
    // All event scopes.
    var eventScopes = [UUID]()
    
    func owner(for entityId : UUID) -> ComponentController? {
        guard let componentId = ownedEntities[entityId] else {
            return nil
        }
        
        return controllers[componentId]
    }
    
    func displayName(for entityId : UUID) -> String {
        let componentName = type(of: owner(for: entityId)?.component ?? TransientComponent(content: EmptyView()))
        let entityName = displayNamesOfEntities[entityId] ?? entityId.uuidString
        
        return "\(componentName).\(entityName)"
    }
    
    func environmentValues(for id : UUID) -> EnvironmentValues {
        environmentValues[id] ?? EnvironmentValues()
    }
    
    var currentEventScope : ComponentController? {
        guard let componentId = eventScopes.last else {
            return nil
        }
        
        return controllers[componentId]
    }
    
    func pushEventScope(for id : UUID?) {
        guard let id = id else {
            return
        }
        
        eventScopes.append(id)
    }
    
    func popEventScope() {
        eventScopes.removeLast()
    }
    
}

class ComponentController : UIHostingController<AnyView> {
    
    // ID of underlying component.
    let id : UUID
    
    // Shape of underlying component.
    let component : Component
    
    // Children components.
    var subcontrollers = [ComponentController]()
    
    // Lifecycle emitters.
    let didCreate = SignalEmitter()
    let didDestroy = SignalEmitter()
    let didAppear = SignalEmitter()
    let didDisappear = SignalEmitter()

    // Various observers
    let didMoveOutOfParent = PassthroughSubject<Void, Never>()
    
    // Cancellables that are managed by this contorller.
    fileprivate var cancellables = Set<ComposeCancellable>()
    
    deinit {
        print("[CCC] - '\(type(of: component))'")
        
        cancellables.forEach {
            $0.cancel()
        }
        
        cancellables.removeAll()
        
        didDestroy.send()
        
        ComponentControllerStorage.shared.controllers[self.id] = nil
    }
    
    init(component : Component) {
        print("[CCC] + '\(type(of: component))'")
        
        self.id = component.id
        self.component = component
        
        super.init(rootView: component.view)
      
        ComponentControllerStorage.shared.controllers[self.id] = self
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ComponentController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didCreate.send()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear.send()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        didDisappear.send()
        super.viewDidDisappear(animated)
        
        if parent == nil {
            didMoveOutOfParent.send()
        }
    }
    
}

extension ComponentController {
    
    func addChildController(_ controller : ComponentController) {
        self.subcontrollers.append(controller)
    }
    
}

extension ComponentController {
    
    class ComposeCancellable : Hashable, Equatable {
      
        static func == (lhs: ComponentController.ComposeCancellable, rhs: ComponentController.ComposeCancellable) -> Bool {
            lhs.id == rhs.id
        }
        
        let id : UUID
        let cancellable : AnyCancellable?
        
        init(id: UUID, cancellable: AnyCancellable? = nil) {
            self.id = id
            self.cancellable = cancellable
        }
        
        deinit {
            cancellable?.cancel()
        }
        
        func cancel() {
            cancellable?.cancel()
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    func addObserver(_ cancellable : AnyCancellable, for id : UUID = UUID()) {
        self.cancellables.insert(.init(id: id, cancellable: cancellable))
    }
    
    func removeObserver(for id : UUID) {
        self.cancellables.remove(.init(id: id))
    }
    
}

extension ComponentController {
    
    var isModal : Bool {
        parent is RouterNavigationController == false
    }
    
}
