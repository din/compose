import Foundation
import SwiftUI

class ComposeAppStorage {
    static var RootType : StartupComponent.Type? = nil
    
    static weak var rootComponentController : ComponentController? = nil
}

struct ComposeApp : App {
    
    var body: some Scene {
        WindowGroup {
            EmptyView()
                .onAppear {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                        return
                    }
                    
                    guard let window = windowScene.windows.first else {
                        return
                    }
    
                    ComposeAppStorage.RootType?.willBindRootComponent()
                    
                    window.rootViewController = ComposeAppStorage.RootType?.init().bind()
                    
                    ComposeAppStorage.RootType?.didBindRootComponent()
                    
                    ComposeAppStorage.rootComponentController = window.rootViewController as? ComponentController
                }
        }
    }
    
}
