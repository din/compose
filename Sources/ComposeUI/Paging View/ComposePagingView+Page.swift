#if os(iOS)

import Foundation
import UIKit
import SwiftUI
import Compose

extension ComposePagingView {
    
    class PageCell : UICollectionViewCell {

        fileprivate var hostingView = UIHostingView<AnyView>(rootView: AnyView(EmptyView()))
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            makeEmptyHostingView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateContent(to content : Content, shouldRecreateView : Bool = false) {
            if shouldRecreateView == true {
                makeEmptyHostingView()
            }

            hostingView.rootView = AnyView(content.edgesIgnoringSafeArea(.all))
        }
        
        fileprivate func makeEmptyHostingView() {
            hostingView.removeFromSuperview()
            
            hostingView = UIHostingView<AnyView>(rootView: AnyView(EmptyView()))
            
            contentView.addSubview(hostingView)
            
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            hostingView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            hostingView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
        
    }
    
    
}

#endif
