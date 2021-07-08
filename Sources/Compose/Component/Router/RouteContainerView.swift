import Foundation
import SwiftUI

///This view resets all animation conexts of underlying views and makes top-level animations smoother.
struct RouteContainerView<Content: View>: UIViewControllerRepresentable {
    
    let content: Content
    
    init(@ViewBuilder content : () -> Content) {
        self.content = content()
    }
    
    init(content : Content) {
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIHostingController(rootView: content)
        controller.view.backgroundColor = .clear
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
}
