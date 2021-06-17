import Foundation
import Compose
import SwiftUI

public struct ComposeNavigationBar<LeftView : View, RightView : View> : View {
    
    @Environment(\.composeNavigationBarStyle) var style
    
    public let title : String
    public let leftView : LeftView
    public let rightView : RightView
    
    public init(title : String,
                leftView : LeftView,
                rightView : RightView) {
        self.title = title
        self.leftView = leftView
        self.rightView = rightView
    }

    public var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 0) {
                leftView
                    .foregroundColor(style.tintColor)
     
                Spacer()
                   
                rightView
                    .foregroundColor(style.tintColor)
            }
            .offset(y: 2)
            
            GeometryReader { info in
                if leftView is EmptyView == false || style.alwaysCenterTitle == true {
                    Text(NSLocalizedString(title, comment: ""))
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .position(x: info.frame(in: .local).midX, y: info.frame(in: .local).midY)
                        .frame(maxWidth: info.size.width * 0.7)
                }
                else {
                    Text(NSLocalizedString(title, comment: ""))
                        .font(.system(size: 18, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .position(x: info.frame(in: .local).midX, y: info.frame(in: .local).midY)
                }
            }
            .truncationMode(.tail)
            .lineLimit(1)
            .offset(y: 2)
        
            if style.shouldShowDivider == true {
                VStack {
                    Divider()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, -style.horizontalPadding)
            }
        }
        .font(.system(size: 16, weight: .semibold, design: .default))
        .frame(height: style.height)
        .padding(.horizontal, style.horizontalPadding)
        .overlay(
            Rectangle()
                .fill(style.backgroundColor)
                .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100)
                .offset(y: -100),
            alignment: .top
        )
        .background(style.backgroundColor)
        .foregroundColor(style.foregroundColor)
    }
    
}
