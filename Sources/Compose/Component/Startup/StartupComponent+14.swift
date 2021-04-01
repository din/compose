import Foundation
import SwiftUI

@available(iOS 14.0, *)
struct ComposeApp : App {
    
    var body: some Scene {
        WindowGroup {
            RuntimeStorage.RootComponent?.view
        }
    }
    
}
