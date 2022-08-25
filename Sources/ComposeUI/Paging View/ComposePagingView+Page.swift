#if os(iOS)

import Foundation
import UIKit
import SwiftUI
import Compose

extension ComposePagingView {
    
    class HostingController : UIHostingController<AnyView> {
        
        var isTransition = false
        var index : Int = 0
        
    }
    
}

#endif
