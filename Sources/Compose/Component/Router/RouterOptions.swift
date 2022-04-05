import Foundation

public struct RouterOptions {
    
    public var shouldClearWhenNotPresented : Bool = false
    
    public init(shouldClearWhenNotPresented : Bool = false) {
        self.shouldClearWhenNotPresented = shouldClearWhenNotPresented
    }
    
}
