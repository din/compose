#if os(iOS)

import Foundation
import UIKit
import SwiftUI
import Compose

extension ComposePagingView {
    
    class PageCell : UICollectionViewCell {
        
        var content : Content? = nil {
            
            didSet {
                updateContent()
            }
            
        }
        
        fileprivate var hostingView = UIHostingView<AnyView>(rootView: AnyView(EmptyView()))
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(hostingView)
            
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            hostingView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            hostingView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        fileprivate func updateContent() {
            guard let content = content else {
                return
            }

            hostingView.rootView = AnyView(content.edgesIgnoringSafeArea(.all))
        }
        
    }
    
    
}

#endif
