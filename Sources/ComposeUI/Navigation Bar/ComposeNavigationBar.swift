import Foundation
import Compose
import SwiftUI

public struct ComposeNavigationBar<LeftView : View, RightView : View> : View {
    
    @Environment(\.composeNavigationBarStyle) var style
    @Environment(\.presentationMode) var presentationMode
    
    public let title : String
    public let leftView : LeftView
    public let rightView : RightView
    
    public init(title : String,
                @ViewBuilder leftView : () -> LeftView,
                @ViewBuilder rightView : () -> RightView) {
        self.title = title
        self.leftView = leftView()
        self.rightView = rightView()
    }

    public var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                
                HStack(alignment: .center, spacing: 0) {
                    leftView
         
                    Spacer()
                       
                    rightView
                }
                
                GeometryReader { info in
                    if leftView is EmptyView == false {
                        Text(NSLocalizedString(title, comment: ""))
                            .font(.headline)
                            .position(x: info.frame(in: .local).midX, y: info.frame(in: .local).midY)
                            .frame(maxWidth: info.size.width * 0.7)
                    }
                    else {
                        Text(NSLocalizedString(title, comment: ""))
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .position(x: info.frame(in: .local).midX, y: info.frame(in: .local).midY)
                    }
                }
                .truncationMode(.tail)
                .lineLimit(1)
                
            }
            .offset(y: -3)
        }
        .frame(height: style.height)
        .padding(.horizontal, style.padding)
        
        
    }
    
}
