import Foundation
import SwiftUI

struct ComposeSheetContainerView<Content : View, Background : View> : View {
    
    @Environment(\.composeNavigationBarStyle) var navigationBarStyle
    @EnvironmentObject var manager : ComposeSheetManager
    
    let content : Content
    let background : Background
    
    init(content : @autoclosure () -> Content, background : @autoclosure () -> Background) {
        self.content = content()
        self.background = background()
    }
    
    var body: some View {
        content
        .sheet(isPresented: manager.hasSheet) {
            ZStack {
                background
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(5)
                
                manager.sheet?
                    .zIndex(6)
                    .environment(\.composeNavigationBarStyle, navigationBarStyle)
            }
        }
    }
    
}
