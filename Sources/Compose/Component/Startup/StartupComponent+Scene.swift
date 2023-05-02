import Foundation
import SwiftUI

class ComposeAppStorage {
    static var RootType : StartupComponent.Type? = nil
    
    static weak var rootComponentController : ComponentController? = nil
}

struct ComposeRootView : UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ComponentController {
        ComposeAppStorage.RootType?.willBindRootComponent()
        
        guard let rootComponentController = ComposeAppStorage.RootType?.init().bind() else {
            return ComponentController(component: TransientComponent(content: EmptyView()))
        }
        
        ComposeAppStorage.RootType?.didBindRootComponent()
        
        ComposeAppStorage.rootComponentController = rootComponentController
        
        return rootComponentController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
}

struct ComposeApp : App {
    
    @UIApplicationDelegateAdaptor(ComposeAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ComposeRootView()
                .edgesIgnoringSafeArea(.all)
        }
    }
    
}
