import Foundation
import SwiftUI
import UIKit

fileprivate struct ComposeSheetPresenterView<Content : View> : UIViewControllerRepresentable {
    
    let content : Content
    let shouldPreventDismissal : Bool
    
    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        let controller = UIHostingController(rootView: content)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        uiViewController.rootView = content
        uiViewController.parent?.isModalInPresentation = shouldPreventDismissal == true
    }
    
}

extension View {
    
    func composeSheetDismissable(shouldPreventDismissal : Bool) -> some View {
        ComposeSheetPresenterView(content: self,
                                  shouldPreventDismissal: shouldPreventDismissal)
    }
    
}
