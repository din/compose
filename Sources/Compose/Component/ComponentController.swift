import Foundation
import SwiftUI
import UIKit
import Combine

public protocol ComponentEntry {
    
    var id : UUID { get }
    
}

extension ComponentEntry {

    var parentController : ComponentController? {
        ComponentControllerStorage.shared.owner(for: self.id)
    }
    
}

class ComponentControllerStorage {
    
    static let shared = ComponentControllerStorage()
    
    // All owned entries. Key is the entry ID, value is the ID of controller which owns the entity.
    var ownedEntities = [UUID : UUID]()
    
    // All controllers in the app.
    var controllers = WeakDictionary<UUID, ComponentController>()
    
    func owner(for entityId : UUID) -> ComponentController? {
        guard let componentId = ownedEntities[entityId] else {
            return nil
        }
        
        return controllers[componentId]
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
    let didDestroy = SignalEmitter()
    let didAppear = SignalEmitter()
    let didDisappear = SignalEmitter()

    // Various observers
    let didMoveOutOfParent = PassthroughSubject<Void, Never>()
    
    // Cancellables that are managed by this contorller.
    fileprivate var cancellables = [UUID : AnyCancellable]()
    
    deinit {
        print("[CCC] - '\(type(of: component))'")
        
        cancellables.values.forEach {
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
    
    func addObserver(_ cancellable : AnyCancellable, for id : UUID) {
        self.cancellables[id] = cancellable
    }
    
    func removeObserver(for id : UUID) {
        self.cancellables[id]?.cancel()
        self.cancellables[id] = nil
    }
    
}

extension ComponentController {
    
    var isModal : Bool {
        parent is RouterNavigationController == false
    }
    
}
