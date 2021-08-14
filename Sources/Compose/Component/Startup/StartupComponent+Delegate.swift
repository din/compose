import Foundation
import SwiftUI

#if os(iOS)

class ComposeAppDelegate: UIResponder, UIApplicationDelegate {

}

class ComposeSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let root = RuntimeStorage.RootComponent else {
            fatalError("Cannot find root component for Compose Runtime.")
        }
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: root.view)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
}

#endif
