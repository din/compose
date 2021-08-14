import Foundation
import SwiftUI

//#if os(iOS)

@available(iOS 14.0, *)
@available(macOS 11, *)
struct ComposeApp : App {
    
    var body: some Scene {
        WindowGroup {
            RuntimeStorage.RootComponent?.view
        }
    }
    
}
