#if os(iOS)

import Foundation
import SwiftUI

public struct ComposeModalContainerView : View {
    
    @EnvironmentObject var manager : ComposeModalManager
    
    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            ForEach(manager.presenters) { presenter in
                presenter.modal.backgroundView
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(Double(presenter.zIndex))
                    .environmentObject(manager)

                presenter.modal.modalView
                    .zIndex(100.0 + Double(presenter.zIndex))
            }
        }
        
    }
    
}

#endif
