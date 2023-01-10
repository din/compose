import Foundation
import SwiftUI

class ComposeAppStorage {
    static var RootType : StartupComponent.Type? = nil
    
    static weak var rootComponentController : ComponentController? = nil
}

class ComposeAppDelegate : NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: connectingSceneSession.configuration.name,
                                                 sessionRole: connectingSceneSession.role)
        configuration.delegateClass = ComposeSceneDelegate.self
        return configuration
    }
    
}
 
class ComposeSceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window : UIWindow? = nil
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        ComposeAppStorage.RootType?.willBindRootComponent()
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ComposeAppStorage.RootType?.init().bind()
        window.makeKeyAndVisible()
        
        ComposeAppStorage.RootType?.didBindRootComponent()
        
        ComposeAppStorage.rootComponentController = window.rootViewController as? ComponentController
        
        self.window = window
    }
    
}
