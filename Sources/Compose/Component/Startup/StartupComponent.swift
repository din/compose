import Foundation
import SwiftUI

public protocol StartupComponent : Component {

    init()
    
    static func willBindRootComponent()
    static func didBindRootComponent()
    
}

class RuntimeStorage {
    static var RootComponent : Component? = nil
}

extension StartupComponent {
    
    public static func main() {
        willBindRootComponent()
        RuntimeStorage.RootComponent = self.init().bind()
        didBindRootComponent()
        
        if #available(iOS 14.0, *) {
            ComposeApp.main()
        } else {
            UIApplicationMain(
                CommandLine.argc,
                CommandLine.unsafeArgv,
                nil,
                NSStringFromClass(ComposeAppDelegate.self)
            )
        }
    }
    
}
