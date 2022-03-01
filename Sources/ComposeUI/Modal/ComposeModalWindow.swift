#if os(iOS)

import UIKit
import SwiftUI

class ComposeModalWindow : UIWindow {
    
    struct PassthroughView : UIViewRepresentable {
        typealias UIViewType = Self.View
        
        class View : UIView {
            
            override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
                return nil
            }
            
        }
        
        func makeUIView(context: Context) -> View {
            let view = Self.View()
            return view
        }
        
        func updateUIView(_ uiView: View, context: Context) {
            //Nothing to do
        }
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == rootViewController?.view.subviews.first {
            return nil
        }
        
        return view
    }
    
}

#endif
