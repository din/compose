import Foundation
import SwiftUI
import simd
import Combine

#if os(iOS)
import UIKit
#endif

protocol RouterNavigationControllerInteractiveDelegate : AnyObject {
    
    func routerNavigationControllerDidFinishInteractivePop(_ routerNavigationController : RouterNavigationController)
    
}

class RouterNavigationController : UINavigationController, UIGestureRecognizerDelegate {
    
    weak var router : Router? = nil
    weak var interactiveDelegate : RouterNavigationControllerInteractiveDelegate? = nil
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        let controller = super.popViewController(animated: animated)
        
        if animated == true, let coordinator = transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { [weak self] context in
                guard context.initiallyInteractive == true && context.isCancelled == false else {
                    return
                }
                
                if let self = self {
                    self.interactiveDelegate?.routerNavigationControllerDidFinishInteractivePop(self)
                }
            }
           
            return controller
        }
        
        return controller
    }

}

class RouterNavigationBar : UINavigationBar {
    
    override var barPosition: UIBarPosition {
        .topAttached
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: UIScreen.main.bounds.width, height: 1.0)
    }
    
}

public struct RouterView<Content : View> : View {
 
    let router : Router
    let content : () -> Content
    
    public init(_ router : Router, @ViewBuilder content : @escaping () -> Content) {
        self.router = router
        self.content = content
    }
    
    public var body : some View {
        RouterContentView(router, content: content)
            .edgesIgnoringSafeArea(.all)
    }
    
}

extension RouterView where Content == EmptyView {
    
    public init(_ router : Router) {
        self.router = router
        self.content = { EmptyView() }
    }
    
}

public struct RouterContentView<Content : View> : UIViewControllerRepresentable, Identifiable {
    
    ///Identifier on a router view allows us to switch between similar nested router views inside other router views.
    ///Without identifiers, SwiftUI wouldn't replace a view inside a `ForEach` statement because they would be identical to SwiftUI.
    @State public fileprivate(set) var id = UUID()
    
    @ObservedObject var router : Router
    
    ///Default view contents.
    let content : Content
    
    public init(_ router : Router, @ViewBuilder content : () -> Content) {
        self.router = router
        self.content = content()
    }
    
    public func makeUIViewController(context: Context) -> UINavigationController {
        let controller = RouterNavigationController(navigationBarClass: RouterNavigationBar.self, toolbarClass: nil)
        controller.router = router
        
        var children : [UIViewController] = (router.paths).compactMap {
            router.controller(for: $0)
        }
        
        if type(of: content) != EmptyView.self {
            let rootController = UIHostingController(rootView: content)
            children.insert(rootController, at: 0)
        }

        controller.navigationBar.isHidden = true
        controller.navigationBar.isTranslucent = false
        controller.setViewControllers(children, animated: false)
        controller.interactivePopGestureRecognizer?.delegate = context.coordinator
        controller.interactiveDelegate = context.coordinator

        context.coordinator.navigationController = controller
        
        return controller
    }
    
    public func updateUIViewController(_ viewController: UINavigationController, context: Context) {
        if type(of: content) != EmptyView.self, let controller = viewController.viewControllers
            .compactMap({ $0 as? UIHostingController<Content> }).first {
            controller.rootView = content
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(router: router)
    }
    
}

extension RouterContentView {
    
    public class Coordinator : NSObject, UIGestureRecognizerDelegate, RouterNavigationControllerInteractiveDelegate {
        
        weak var navigationController : RouterNavigationController? = nil
        
        fileprivate var cancellables = Set<AnyCancellable>()
        fileprivate var observer : NSKeyValueObservation?
        
        init(router : Router?) {
            super.init()
            
            router?.didPerformAction.sink { [weak self] action in
                
                switch action {
                    
                case .push(let animated):
                    guard let path = router?.paths.last, let controller = router?.controller(for: path) else {
                        return
                    }
        
                    self?.navigationController?.pushViewController(controller, animated: animated)
                    
                case .pop(let animated):
                    self?.navigationController?.popViewController(animated: animated)
                    
                case .popToRoot(let animated):
                    self?.navigationController?.popToRootViewController(animated: animated)
                    
                case .replace(let animated):
                    guard let path = router?.paths.first, let controller = router?.controller(for: path) else {
                        return
                    }
                    
                    self?.navigationController?.setViewControllers([controller], animated: animated)
                
                case .clear:
                    self?.navigationController?.setViewControllers([], animated: false)
                    
                }
                
            }.store(in: &cancellables)
        }
        
        deinit {
            cancellables.forEach {
                $0.cancel()
            }
            
            cancellables.removeAll()
        }
        
        public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard gestureRecognizer == navigationController?.interactivePopGestureRecognizer else {
                return true
            }

            return navigationController?.viewControllers.count ?? 0 > 1
        }
        
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
        
        func routerNavigationControllerDidFinishInteractivePop(_ routerNavigationController: RouterNavigationController) {
            guard self.navigationController?.router?.paths.count ?? 0 > 0 else {
                return
            }
            
            self.navigationController?.router?.paths.removeLast()
        }
        
    }
    
}
 
extension RouterContentView where Content == EmptyView {
    
    public init(_ router : Router) {
        self.router = router
        self.content = EmptyView()
    }
    
}

