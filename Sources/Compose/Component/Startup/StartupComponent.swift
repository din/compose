import Foundation
import SwiftUI

public protocol StartupComponent : Component {

    init()
    
    static func willBindRootComponent()
    static func didBindRootComponent()
    
}

extension StartupComponent {
    
    public static func main() {
        ComposeAppStorage.RootType = Self.self
        ComposeApp.main()
    }
    
}
