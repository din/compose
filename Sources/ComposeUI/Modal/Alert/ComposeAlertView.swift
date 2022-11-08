#if os(iOS)

import Foundation
import SwiftUI

public struct ComposeAlertView : ComposeModal {
 
    @EnvironmentObject private var manager : ComposeModalManager
    @Environment(\.composeAlertViewStyle) private var style
    
    public let id = UUID()
    
    public let title : LocalizedStringKey?
    public let message : LocalizedStringKey?
    public let mode : ComposeAlertViewPresentationMode
    public let actions : [ComposeAlertAction]
    
    public init(title : LocalizedStringKey? = nil,
                message : LocalizedStringKey? = nil,
                mode : ComposeAlertViewPresentationMode = .alert,
                @ComposeAlertActionBuilder actions : () -> [ComposeAlertAction]) {
        self.title = title
        self.message = message
        self.mode = mode
        self.actions = actions()
    }
    
    public var body: some View {
        if mode == .alert {
            Rectangle()
                .fill(style.alertOverlayColor)
                .edgesIgnoringSafeArea(.all)
            
            alertBody
        }
        else {
            Rectangle()
                .fill(style.sheetOverlayColor)
                .edgesIgnoringSafeArea(.all)
            
            sheetBody
        }
    }
    
    fileprivate var alertBody : some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            VStack(spacing: 0) {
                
                if let title = title {
                    Text(title)
                        .font(.headline)
                        .padding(.top, style.alertVerticalPadding)
                    
                    Spacer()
                        .frame(height: 10)
                }
                
                if let message = message {
                    Text(message)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .lineLimit(nil)
                        .lineSpacing(3)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, style.alertVerticalPadding)
                        .padding(.horizontal, style.alertHorizontalPadding)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                
                HStack(spacing: 0) {
                    ForEach(actions) { action in
                        Button(action: {
                            manager.dismiss(id: id)
                            action.handler()
                        }) {
                            action.content
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
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
                style.background
                    .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(Color(UIColor.separator).opacity(0.5))
            )
            .padding(.horizontal, style.alertOuterHorizontalPadding)
            
            Spacer()
        }
        .transition(
            AnyTransition.opacity
                .combined(with: AnyTransition.scale(scale: 0.91))
                .combined(with: AnyTransition.offset(x: 0, y: -20))
        )
    }
    
    fileprivate var sheetBody : some View {
        ZStack(alignment: .bottom) {
            
            style.sheetOverlayColor.opacity(0.00001)
                .edgesIgnoringSafeArea(.all)
                .contentShape(Rectangle())
                .onTapGesture {
                    manager.dismiss(id: id)
                }

            VStack(spacing: 0) {
                if let title = title {
                    Text(title)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(style.foregroundColor.opacity(0.7))
                        .padding(.vertical, style.sheetVerticalSpacing)
                    
                    Divider()
                }
                
                ForEach(actions) { action in
                    if action.isCustom == false {
                        Button(action: {
                            manager.dismiss(id: id)
                            action.handler()
                        }) {
                            action.content
                                .frame(maxWidth: .infinity, alignment: .center)
                                .contentShape(Rectangle())
                        }
                        .foregroundColor(action.kind == .destructive ? style.destructiveColor : style.actionColor)
                        .padding(.vertical, style.sheetVerticalSpacing)
                    }
                    else {
                        action.content
                    }
                    
                    if action != actions.last {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                style.background
                    .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
            )
            .padding(.horizontal, style.sheetHorizontalPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(
            .move(edge: .bottom).animation(.easeOut(duration: 0.18))
        )
    }
    
}

struct ComposeAlertView_Previews: PreviewProvider {
    
    static var alert : some View {
        ComposeAlertView(title: "Delete Post",
                         message: "Are you sure you want to delete this post? This action cannot be undone.",
                         mode: .sheet) {
            
            ComposeAlertAction {
                Text("Custom Content Thing")
                    .padding(.vertical, 40)
            }
            
            ComposeAlertAction(title: "Delete", kind: .destructive)
            ComposeAlertAction(title: "Cancel")
        }
        .composeAlertViewStyle(
            ComposeAlertViewStyle(background: Color.black,
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

#endif
