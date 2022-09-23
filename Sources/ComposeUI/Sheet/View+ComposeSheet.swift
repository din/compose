#if os(iOS)

import Foundation
import SwiftUI

extension View {
    
    public func addComposeSheet(_ manager : ComposeSheetManager) -> some View {
        ComposeSheetContainerView(content: self)
            .environmentObject(manager)
    }
    
}

#endif
