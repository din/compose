#if os(iOS)

import SwiftUI
import Compose

fileprivate struct NavigationBarInsetsModifier : ViewModifier {
    
    @Environment(\.composeNavigationBarStyle) var barStyle
    
    func body(content: Content) -> some View {
        content.padding(.top, barStyle.height)
    }
    
}

extension View {
    
    public func composeNavigationBar<LeftView : View, RightView : View>(title : LocalizedStringKey,
                                                                        @ViewBuilder leftView : @escaping () -> LeftView,
                                                                        @ViewBuilder rightView : @escaping () -> RightView) -> some View {
        ComposeNavigationContainer(title: title, content: self, leftView: leftView(), rightView: rightView())
    }
    
    public func composeNavigationBar<LeftView : View>(title : LocalizedStringKey,
                                                      @ViewBuilder leftView : @escaping () -> LeftView) -> some View {
        ComposeNavigationContainer(title: title, content: self, leftView: leftView(), rightView: EmptyView())
    }
    
    public func composeNavigationBar<RightView : View>(title : LocalizedStringKey,
                                                       @ViewBuilder rightView : @escaping () -> RightView) -> some View {
        ComposeNavigationContainer(title: title, content: self, leftView: EmptyView(), rightView: rightView())
    }
    
    public func composeNavigationBar(title : LocalizedStringKey) -> some View {
        ComposeNavigationContainer(title: title, content: self, leftView: EmptyView(), rightView: EmptyView())
    }
    
    public func composeNavigationBar(title : LocalizedStringKey,
                              backButtonEmitter : SignalEmitter) -> some View {
        ComposeNavigationContainer(title: title,
                                   content: self,
                                   leftView: ComposeNavigationBackButton(emitter: backButtonEmitter),
                                   rightView: EmptyView())
    }
    
    public func composeNavigationBar<RightView : View>(title : LocalizedStringKey,
                                                       backButtonEmitter : SignalEmitter,
                                                       @ViewBuilder rightView : @escaping () -> RightView) -> some View {
        ComposeNavigationContainer(title: title,
                                   content: self,
                                   leftView: ComposeNavigationBackButton(emitter: backButtonEmitter),
                                   rightView: rightView())
    }
    
}

extension View {
    
    public func adjustComposeNavigationBarInsets() -> some View {
        self.modifier(NavigationBarInsetsModifier())
    }
    
    public func overlayComposeNavigationBar() -> some View {
        self.transformEnvironment(\.composeNavigationBarStyle) { value in
            value.isOverlayingContent = true
            value.background = .init(Color.clear)
        }
    }
    
}

#endif
