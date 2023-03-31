import Foundation
import SwiftUI

struct ComposeNavigationContainer<Content : View, LeftView : View, RightView : View> : View {
    
    @Environment(\.composeNavigationBarStyle) var barStyle
    @Environment(\.composeNavigationStyle) var style
    
    let title : LocalizedStringKey
    let content : Content
    let leftView : LeftView
    let rightView : RightView
    
    var body: some View {
        ZStack(alignment: .top) {
            style.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            content
                .padding(.top, barStyle.topPadding + (barStyle.isOverlayingContent == true ? 0 : barStyle.height))
            
            ComposeNavigationBar(title: title, leftView: leftView, rightView: rightView)
                .padding(.top, barStyle.topPadding)
        }
    }
    
}
