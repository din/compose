import Foundation
import SwiftUI

public protocol StartupComponent : Component {

    init()
    
    static func willBindRootComponent()
    static func didBindRootComponent()
    
    static var applicationDelegateType : AnyComposeAppDelegate.Type { get }
    
}

extension StartupComponent {
    
    public static var applicationDelegateType : AnyComposeAppDelegate.Type {
        EmptyAppDelegate.self
    }
    
}

extension StartupComponent {
    
    public static func main() {
        ComposeAppStorage.RootType = Self.self
        ComposeApp.main()
    }
    
}
