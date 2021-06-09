import Foundation
import SwiftUI
import UIKit

fileprivate struct ComposeSheetPresenterView : UIViewControllerRepresentable {
    
    let shouldPreventDismissal : Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            uiViewController.parent?.isModalInPresentation = shouldPreventDismissal == true
        }
    }
    
}

extension View {
    
    func composeSheetDismissable(shouldPreventDismissal : Bool) -> some View {
        self
            .background(ComposeSheetPresenterView(shouldPreventDismissal: shouldPreventDismissal))
    }
    
}
