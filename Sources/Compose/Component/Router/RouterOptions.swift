import Foundation

public struct RouterOptions {
    
    public var shouldClearWhenNotPresented : Bool
    public var shouldScopeAnimations : Bool
    
    public init(shouldClearWhenNotPresented : Bool = false,
                scopesAnimations : Bool = false) {
        self.shouldClearWhenNotPresented = shouldClearWhenNotPresented
        self.shouldScopeAnimations = scopesAnimations
    }
    
}
