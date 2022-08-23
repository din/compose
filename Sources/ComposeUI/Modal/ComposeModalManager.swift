#if os(iOS)

import Foundation
import SwiftUI
import Compose

final public class ComposeModalManager : ObservableObject {
    
    struct Presenter : Identifiable {
        
        var id: UUID {
            modal.id
        }
        
        let modal : AnyComposeModal
        let zIndex : Int
        
    }
    
    @Published var presenters = [Presenter]()
    @Published var sheet : AnyView? = nil

    fileprivate var window : ComposeModalWindow? = nil

    public init(_ wrapper : @escaping ((ComposeModalContainerView) -> AnyView) = { view in AnyView(view) }) {
        attachWindow(wrapper)
        
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: .main) { [weak self] _ in
            self?.attachWindow(wrapper)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.attachWindow(wrapper)
        }
    }
    
    public func present(_ modal : AnyComposeModal) {
        withAnimation {
            presenters.append(.init(modal: modal, zIndex: presenters.count))
        }
        
        window?.isUserInteractionEnabled = true
    }
    
    public func dismiss(id : UUID? = nil) {
        guard presenters.count > 0 else {
            return
        }
        
        withAnimation {
            if let id = id {
                presenters.removeAll(where: { $0.id == id })
            }
            else {
                _ = presenters.removeLast()
            }
            
            if presenters.count == 0 {
                window?.isUserInteractionEnabled = false
            }
        }
        
    }
    
}

extension ComposeModalManager {
    
    fileprivate func attachWindow(_ wrapper : @escaping ((ComposeModalContainerView) -> AnyView)) {
        guard window == nil else {
            return
        }
        
        guard let windowScene = UIApplication.shared
                .connectedScenes
                .first as? UIWindowScene else {
            return
        }
        
        let rootView = wrapper(ComposeModalContainerView())
            .environmentObject(self)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ComposeModalWindow.PassthroughView())
            .transformEnvironment(\.composeAlertViewStyle) { value in
                value = .init()
            }
        
        let window = ComposeModalWindow(windowScene: windowScene)
        window.windowLevel = .alert
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
        window.isUserInteractionEnabled = false
        window.backgroundColor = UIColor.clear
        window.rootViewController?.view.backgroundColor = .clear
        
        self.window = window
    }
    
}

#endif
