import Foundation

public final class MappedStore<Target, TargetStore : AnyStore> : ObservableObject, Bindable {
    
    let keyPath : KeyPath<Target, TargetStore>
    
    @Published public var state : TargetStore.State
    @Published public var status : Set<TargetStore.Status>
    
    public init(for keyPath : KeyPath<Target, TargetStore>) {
        self.keyPath = keyPath
        self.state = .init()
        self.status = .init()
    }
    
    public func bind<C : Component>(to component: C) {
        guard let component = component as? Target else {
            return
        }
        
        let store = component[keyPath: keyPath]
        
        store.didChange ++= { state in
            self.state = state
        }
        
        store.didStatusChange ++= { status in
            self.status = status
        }
    }
    
}
