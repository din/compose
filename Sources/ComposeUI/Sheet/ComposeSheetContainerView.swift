import Foundation
import SwiftUI

struct ComposeSheetContainerView<Content : View, Background : View> : View {
    
    @Environment(\.composeNavigationBarStyle) var navigationBarStyle
    @Environment(\.composeNavigationStyle) var navigationStyle
    @EnvironmentObject var manager : ComposeSheetManager
    
    let content : Content
    let background : Background
    
    init(content : @autoclosure () -> Content, background : @autoclosure () -> Background) {
        self.content = content()
        self.background = background()
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            if manager.style == .cover {
                content
                    .fullScreenCover(isPresented: manager.hasContent) {
                        content(for: manager.style)
                    }
            }
            else {
                content
                    .sheet(isPresented: manager.hasContent) {
                        content(for: manager.style)
                    }
            }
        } else {
            content
                .sheet(isPresented: manager.hasContent) {
                    content(for: .sheet)
                }
        }
    }
    
    fileprivate func content(for style : ComposeSheetPresentationStyle) -> some View {
        ZStack {
            background
                .edgesIgnoringSafeArea(.all)
                .zIndex(5)
            
            if style == .sheet {
                manager.content
                    .composeSheetDismissable(shouldPreventDismissal: manager.shouldPreventDismissal)
                    .zIndex(6)
                    .environment(\.composeNavigationBarStyle, navigationBarStyle)
                    .environment(\.composeNavigationStyle, navigationStyle)
            }
            else {
                manager.content
                    .zIndex(6)
                    .environment(\.composeNavigationBarStyle, navigationBarStyle)
                    .environment(\.composeNavigationStyle, navigationStyle)
            }
        }
    }
    
}
