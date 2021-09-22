import Foundation
import SwiftUI
import UIKit
import Combine

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

fileprivate struct ComposeFullScreenCoverView<Content : View> : UIViewRepresentable {
  
    fileprivate class Coordinator {
        
        let controller : UIHostingController<Content>
        
        init(content : Content) {
            self.controller = UIHostingController(rootView: content)
            controller.modalPresentationStyle = .fullScreen
        }
        
        func present() {
            guard controller.isBeingPresented == false else {
                return
            }
            
            UIApplication.shared.topViewController?.present(controller, animated: true, completion: nil)
        }
        
        func dismiss() {
            guard controller.isBeingPresented == true else {
                return
            }
            
            controller.dismiss(animated: true, completion: nil)
        }
        
    }
    
    let isPresented : Bool
    let content : Content
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        
        view.alpha = 0.0
        view.frame = .zero
        view.isUserInteractionEnabled = false
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if isPresented == true {
            context.coordinator.present()
        }
        else {
            context.coordinator.dismiss()
        }
        
        context.coordinator.controller.rootView = content
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(content: content)
    }
  
}

extension View {
    
    func composeSheetDismissable(shouldPreventDismissal : Bool) -> some View {
        self
            .background(ComposeSheetPresenterView(shouldPreventDismissal: shouldPreventDismissal))
    }
    
    func composeFullScreenCover<Content : View>(isPresented : Binding<Bool>, @ViewBuilder content : () -> Content) -> some View {
        self
            .background(ComposeFullScreenCoverView(isPresented: isPresented.wrappedValue, content: content()))
    }
    
}

