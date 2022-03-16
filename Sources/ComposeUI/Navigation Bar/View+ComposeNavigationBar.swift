#if os(iOS)

import SwiftUI
import Compose

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

#endif
