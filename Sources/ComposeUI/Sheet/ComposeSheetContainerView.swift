#if os(iOS)

import Foundation
import SwiftUI

struct ComposeSheetContainerView<Content : View> : View {
    
    @Environment(\.composeNavigationBarStyle) var navigationBarStyle
    @Environment(\.composeNavigationStyle) var navigationStyle
    @EnvironmentObject var manager : ComposeSheetManager
    
    let content : Content
    
    init(content : @autoclosure () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 14.5, *) {
           content
               .fullScreenCover(isPresented: manager.hasContent(with: .cover)) {
                   sheetContent(for: manager.style)
               }
               .sheet(isPresented: manager.hasContent(with: .sheet)) {
                   sheetContent(for: manager.style)
               }
       } else if #available(iOS 14.0, *) {
            content
                .fullScreenCover(isPresented: manager.hasContent(with: .cover)) {
                    sheetContent(for: manager.style)
                }
                .overlay (
                    EmptyView()
                        .sheet(isPresented: manager.hasContent(with: .sheet)) {
                            sheetContent(for: manager.style)
                        }
                )
        } else {
            content
                .sheet(isPresented: manager.hasContent(with: .sheet)) {
                    sheetContent(for: manager.style)
                }
                .composeFullScreenCover(isPresented: manager.hasContent(with: .cover)) {
                    sheetContent(for: manager.style)
                }
        }
    }
    
    @ViewBuilder
    fileprivate func sheetContent(for style : ComposeSheetPresentationStyle) -> some View {
        if style == .sheet {
            manager.content
                .composeSheetDismissable(shouldPreventDismissal: manager.shouldPreventDismissal)
                .environment(\.composeNavigationBarStyle, navigationBarStyle)
                .environment(\.composeNavigationStyle, navigationStyle)
        }
        else {
            manager.content
                .environment(\.composeNavigationBarStyle, navigationBarStyle)
                .environment(\.composeNavigationStyle, navigationStyle)
        }
    }
    
}

#endif
