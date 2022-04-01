import Foundation

public struct RouterOptions {
    
    public var shouldClearWhenNotPresented : Bool
    
    public init(shouldClearWhenNotPresented : Bool = false) {
        self.shouldClearWhenNotPresented = shouldClearWhenNotPresented
    }
    
}
