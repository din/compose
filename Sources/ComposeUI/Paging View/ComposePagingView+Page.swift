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
        
        fileprivate var hostingView : UIHostingView<Content>? = nil
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        fileprivate func updateContent() {
            guard let content = content else {
                hostingView?.removeFromSuperview()
                hostingView = nil
                return
            }
            
            let view = UIHostingView(rootView: content)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(view)
            
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            
            self.hostingView = view
        }
        
    }
    
}

#endif
