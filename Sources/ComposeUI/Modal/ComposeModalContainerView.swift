import Foundation
import SwiftUI

struct ComposeModalContainerView : View {
    
    @EnvironmentObject var manager : ComposeModalManager
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            
            ForEach(manager.presenters.indices, id: \.self) { index in
                manager.presenters[index].background
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(Double(index))

                manager.presenters[index].view
                    .zIndex(100.0 + Double(index))
            }
        }
        
    }
    
}
