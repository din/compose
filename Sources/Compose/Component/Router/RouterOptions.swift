import Foundation

public struct RouterOptions {
    
    public var canTransition : Bool
    public var scopesAnimations : Bool
    
    public init(canTransition: Bool = true,
                scopesAnimations : Bool = false) {
        self.canTransition = canTransition
        self.scopesAnimations = scopesAnimations
    }
    
}
