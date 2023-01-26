import Foundation
import UIKit

public protocol AnyComposeAppDelegate : AnyObject, UIApplicationDelegate {
    
    init()
    
}

public class EmptyAppDelegate : NSObject, AnyComposeAppDelegate {
    
    public required override init() {
        super.init()
    }
    
}

class ComposeAppDelegate : NSObject, UIApplicationDelegate {
    
    let proxy = ComposeAppStorage.RootType?.applicationDelegateType.init()
    
    override func responds(to aSelector: Selector!) -> Bool {
        return proxy?.responds(to: aSelector) ?? false
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        guard proxy?.responds(to: aSelector) == true else {
            return nil
        }
        
        return proxy
    }
}
