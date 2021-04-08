import Foundation
import SwiftUI

public struct ComposeAlertView : ComposeModal {
    
    @EnvironmentObject private var manager : ComposeModalManager
    @Environment(\.composeAlertViewStyle) private var style
    
    public let title : String
    public let message : String
    
    public let actions : [ComposeAlertAction]
    
    public init(title : String, message : String, @ComposeAlertActionBuilder actions : () -> [ComposeAlertAction]) {
        self.title = title
        self.message = message
        self.actions = actions()
    }
    
    public var backgroundBody: some View {
        style.overlayColor
            .transition(.opacity)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                
                Text(title)
                    .font(.headline)
                    .padding(.top, style.verticalPadding)
                
                Spacer()
                    .frame(height: 10)
                
                Text(message)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .lineLimit(nil)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, style.verticalPadding)
                    .padding(.horizontal, style.horizontalPadding)
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                
                HStack(spacing: 0) {
                    ForEach(actions) { action in
                        Button(action: {
                            manager.dismiss()
                            action.handler()
                        }) {
                            Text(action.title)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(action.kind == .destructive ? style.destructiveColor : style.actionColor)
                        
                        if action != actions.last {
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 48)
            }
            .foregroundColor(style.foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(style.backgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(UIColor.separator).opacity(0.5))
            )
            .padding(.horizontal, style.outerHorizontalPadding)
            
            Spacer()
        }
        .transition(
            AnyTransition.opacity
                .combined(with: AnyTransition.scale(scale: 0.91))
                .combined(with: AnyTransition.offset(x: 0, y: -20))
        )
    }
    
}

struct ComposeAlertView_Previews: PreviewProvider {
    
    static var alert : some View {
        ComposeAlertView(title: "Delete Post",
                         message: "Are you sure you want to delete this post? This action cannot be undone.") {
            ComposeAlertAction(title: "Cancel")
            ComposeAlertAction(title: "Delete", kind: .destructive)
        }
        .composeAlertViewStyle(
            ComposeAlertViewStyle(backgroundColor: Color.black,
                                  foregroundColor: Color.white,
                                  actionColor: Color.blue)
        )
    }
    
    static var previews: some View {
        Group {
            alert
                .preferredColorScheme(.dark)
            
            alert
        }
        .background(Color.white.opacity(0.2))
    }
}
