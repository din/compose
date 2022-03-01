#if os(iOS)

import SwiftUI
import Compose

extension View {
    
    public func composeNavigationBar<LeftView : View, RightView : View>(title : String,
                                                                        @ViewBuilder leftView : @escaping () -> LeftView,
                                                                        @ViewBuilder rightView : @escaping () -> RightView) -> some View {
        ComposeNavigationContainer(title: title, content: self, leftView: leftView(), rightView: rightView())
    }
    
    public func composeNavigationBar<LeftView : View>(title : String,
                                                      @ViewBuilder leftView : @escaping () -> LeftView) -> some View {
        ComposeNavigationContainer(title: title, content: self, leftView: leftView(), rightView: EmptyView())
    }
    
    public func composeNavigationBar<RightView : View>(title : String,
                                                       @ViewBuilder rightView : @escaping () -> RightView) -> some View {
        ComposeNavigationContainer(title: title, content: self, leftView: EmptyView(), rightView: rightView())
    }
    
    public func composeNavigationBar(title : String) -> some View {
        ComposeNavigationContainer(title: title, content: self, leftView: EmptyView(), rightView: EmptyView())
    }
    
    public func composeNavigationBar(title : String,
                              backButtonEmitter : SignalEmitter) -> some View {
        ComposeNavigationContainer(title: title,
                                   content: self,
                                   leftView: ComposeNavigationBackButton(emitter: backButtonEmitter),
                                   rightView: EmptyView())
    }
    
    public func composeNavigationBar<RightView : View>(title : String,
                                                       backButtonEmitter : SignalEmitter,
                                                       @ViewBuilder rightView : @escaping () -> RightView) -> some View {
        ComposeNavigationContainer(title: title,
                                   content: self,
                                   leftView: ComposeNavigationBackButton(emitter: backButtonEmitter),
                                   rightView: rightView())
    }
    
}

#endif
