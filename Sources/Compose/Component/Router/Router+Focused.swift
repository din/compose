import Foundation

public protocol CustomFocusProvider {
    
    var focusedRouter : Router { get }
    
}

extension Router {
    
    public func updateFocused() {
        if let id = self.routes.last?.id {
            setFocused(id: id)
        }
        else if let component = self.target as? CustomFocusProvider, let id = component.focusedRouter.routes.last?.id {
            setFocused(id: id)
        }
        else if let id = self.target?.id {
            setFocused(id: id)
        }
    }
    
    fileprivate func setFocused(id : UUID) {
        guard let startupDescriptor = Introspection.shared.descriptor(forComponent: Introspection.shared.app.startupComponentId) else {
            return
        }
        
        if let previousId = startupDescriptor.focused {
            Storage.shared.value(at: Storage.PresentationEmitterKey(id: previousId, kind: .leave)) {
                SignalEmitter()
            }.send()
        }
        
        setFocused(id: id, forSubtree: id)

        if let startupDescriptor = Introspection.shared.descriptor(forComponent: Introspection.shared.app.startupComponentId),
           let focusedId = startupDescriptor.focused {
            Storage.shared.value(at: Storage.PresentationEmitterKey(id: focusedId, kind: .enter)) {
                SignalEmitter()
            }.send()
        }
    }
    
    fileprivate func setFocused(id: UUID, forSubtree subtreeId : UUID) {
        var parent : UUID? = nil
        
        Introspection.shared.updateDescriptor(forComponent: subtreeId) { descriptor in
            descriptor?.focused = id
            parent = descriptor?.parent
        }
        
        if let parent = parent {
            setFocused(id: id, forSubtree: parent)
        }
    }
    
}
