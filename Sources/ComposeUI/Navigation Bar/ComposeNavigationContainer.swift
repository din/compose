import Foundation
import SwiftUI

struct ComposeNavigationContainer<Content : View, LeftView : View, RightView : View> : View {
    
    @Environment(\.composeNavigationStyle) var style
    
    let title : LocalizedStringKey
    let content : Content
    let leftView : LeftView
    let rightView : RightView
    
    var body: some View {
        ZStack {
            style.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ComposeNavigationBar(title: title, leftView: leftView, rightView: rightView)
                
                content
            }
        }
    }
    
}
