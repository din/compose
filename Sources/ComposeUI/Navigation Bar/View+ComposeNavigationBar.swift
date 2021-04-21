import SwiftUI
import Compose

extension View {
    
    public func composeNavigationBar<LeftView : View, RightView : View>(title : String,
                                                                        @ViewBuilder leftView : @escaping () -> LeftView,
                                                                        @ViewBuilder rightView : @escaping () -> RightView) -> some View {
        VStack(spacing: 0) {
            ComposeNavigationBar(title: title, leftView: leftView, rightView: rightView)
            
            self
        }
    }
    
    public func composeNavigationBar<LeftView : View>(title : String,
                                                      @ViewBuilder leftView : @escaping () -> LeftView) -> some View {
        VStack(spacing: 0) {
            ComposeNavigationBar(title: title, leftView: leftView, rightView: { EmptyView() })
            
            self
        }
    }
    
    public func composeNavigationBar<RightView : View>(title : String,
                                                       @ViewBuilder rightView : @escaping () -> RightView) -> some View {
        VStack(spacing: 0) {
            ComposeNavigationBar(title: title, leftView: { EmptyView() }, rightView: rightView)
            
            self
        }
    }
    
    public func composeNavigationBar(title : String) -> some View {
        VStack(spacing: 0) {
            ComposeNavigationBar(title: title, leftView: { EmptyView() }, rightView: { EmptyView() })
            
            self
        }
    }
    
    public func composeNavigationBar(title : String,
                              backButtonEmitter : SignalEmitter) -> some View {
        VStack(spacing: 0) {
            ComposeNavigationBar(title: title, leftView: { ComposeNavigationBackButton(emitter: backButtonEmitter) }, rightView: { EmptyView() })
            
            self
        }
    }
    
    public func composeNavigationBar<RightView : View>(title : String,
                                                       backButtonEmitter : SignalEmitter,
                                                       @ViewBuilder rightView : @escaping () -> RightView) -> some View {
        VStack(spacing: 0) {
            ComposeNavigationBar(title: title, leftView: { ComposeNavigationBackButton(emitter: backButtonEmitter) }, rightView: rightView)
            
            self
        }
    }
    
}
