import Foundation
import SwiftUI

struct ComposeNavigationContainer<Content : View, LeftView : View, RightView : View> : View {
    
    let title : String
    let content : Content
    let leftView : LeftView
    let rightView : RightView
    
    var body: some View {
        VStack(spacing: 0) {
            ComposeNavigationBar(title: title, leftView: leftView, rightView: rightView)
            
            content
        }
    }
    
}
