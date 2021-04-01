import Foundation
import SwiftUI
import Compose

final public class ComposeModalManager : ObservableObject {
    
    @Published var presenters = [ComposeModalPresenter]()
    @Published var sheet : AnyView? = nil
    
    fileprivate var window : ComposeModalWindow? = nil
    
    public init() {
        guard let windowScene = UIApplication.shared
                .connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .first as? UIWindowScene else {
            return
        }
        
        let window = ComposeModalWindow(windowScene: windowScene)
        window.windowLevel = .alert
        window.rootViewController = UIHostingController(rootView: ComposeModalContainerView()
                                                            .environmentObject(self)
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                            .background(ComposeModalWindow.PassthroughView()))
        window.makeKeyAndVisible()
        window.isUserInteractionEnabled = false
        window.backgroundColor = UIColor.clear
        window.rootViewController?.view.backgroundColor = .clear

        self.window = window
    }
    
    public func present<Presentable : ComposeModalPresentable>(_ presentable : @autoclosure () -> Presentable) {
        let presentable = presentable()
        
        withAnimation {
            presenters.append(ComposeModalPresenter(view: AnyView(presentable),
                                                    background: AnyView(presentable.background)))
        }
        
        window?.isUserInteractionEnabled = true
    }
    
    public func dismiss() {
        guard presenters.count > 0 else {
            return
        }
        
        withAnimation {
            _ = presenters.removeLast()
            
            if presenters.count == 0 {
                window?.isUserInteractionEnabled = false
            }
        }
        
        
    }
    
}
