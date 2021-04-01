import Foundation
import SwiftUI

extension View {
    
    public func addComposeSheet<Background : View>(_ manager : ComposeSheetManager, background : Background) -> some View {
        ComposeSheetContainerView(content: self, background: background)
            .environmentObject(manager)
    }
    
}
