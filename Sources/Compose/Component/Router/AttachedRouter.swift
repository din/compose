import SwiftUI

public class AttachedRouter {
    
    weak var router : Router? = nil
    
    init() {
        
    }
    
    init(router : Router) {
        self.router = router
    }
    
    public func push(_ keyPath : AnyKeyPath, animated : Bool = true) {
        print("!!! ATTACHED PUSH", keyPath, "COMPONENT", router)
        router?.push(keyPath, animated: animated)
    }
    
    public func pop(animated : Bool = true) {
        router?.pop(animated: animated)
    }
    
}

private struct AttachedRouterKey : EnvironmentKey {
    
    static let defaultValue: AttachedRouter = AttachedRouter()
    
}

extension EnvironmentValues {
    
    public var attachedRouter : AttachedRouter {
        get { self[AttachedRouterKey.self] }
        set { self[AttachedRouterKey.self] = newValue }
    }
    
}
