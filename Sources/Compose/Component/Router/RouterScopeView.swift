import Foundation
import Swift
import SwiftUI

#if os(iOS)
import UIKit

fileprivate class UIHostingView<Content: View>: UIView, UIGestureRecognizerDelegate {
    private let rootViewHostingController: UIHostingController<Content>
    
    public var rootView: Content {
        get {
            return rootViewHostingController.rootView
        } set {
            rootViewHostingController.rootView = newValue
        }
    }
    
    public required init(rootView: Content) {
        self.rootViewHostingController = UIHostingController(rootView: rootView)
        
        super.init(frame: .zero)
        
        rootViewHostingController.view.backgroundColor = .clear
        
        addSubview(rootViewHostingController.view)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        rootViewHostingController.sizeThatFits(in: size)
    }
    
    override open func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        rootViewHostingController.sizeThatFits(in: targetSize)
    }
    
    override open func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        rootViewHostingController.sizeThatFits(in: targetSize)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        rootViewHostingController.view.frame = bounds
    }
    
    override open func sizeToFit() {
        if let superview = superview {
            frame.size = rootViewHostingController.sizeThatFits(in: superview.frame.size)
        } else {
            super.sizeToFit()
        }
    }
    
}

///This view resets all animation conexts of underlying views and makes top-level animations smoother.
fileprivate struct RouterScopeView<Content: View>: UIViewRepresentable {
    
    let content: Content
    
    init(@ViewBuilder content : () -> Content) {
        self.content = content()
    }
    
    init(content : Content) {
        self.content = content
    }
    
    func makeUIView(context: Context) -> some UIView {
        UIHostingView(rootView: content)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
        
}

extension View {
    
    @ViewBuilder
    public func routerScope(_ shouldScope : Bool = true) -> some View {
        if shouldScope == true {
            RouterScopeView(content: self)
        }
        else {
            self
        }
    }
    
}

#else

extension View {
    
    @ViewBuilder
    public func routerScope(_ shouldScope : Bool = true) -> some View {
        self
    }
    
}


#endif
