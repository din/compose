import Foundation
import SwiftUI
import UIKit
import Combine

class TabBarController : UITabBarController {
    
    weak var router : TabRouter? = nil
    
}

public struct TabRouterView : View {
    
    let router : TabRouter
    
    public init(_ router : TabRouter) {
        self.router = router
    }
    
    public var body : some View {
        TabRouterContentView(router)
            .edgesIgnoringSafeArea(.all)
    }
    
}

public struct TabRouterContentView : UIViewControllerRepresentable {
    
    @ObservedObject var router : TabRouter

    public init(_ router: TabRouter) {
        self.router = router
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let controller = TabBarController()
        controller.router = router
        
        let children : [UIViewController] = (router.paths).compactMap {
            router.controller(for: $0)
        }

        controller.setViewControllers(children, animated: false)
        controller.tabBar.isHidden = true
        
        context.coordinator.controller = controller
        
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(router: router)
    }
    
}

extension TabRouterContentView {
    
    public class Coordinator : NSObject {
        
        weak var controller : UITabBarController? = nil
        
        fileprivate var cancellables = Set<AnyCancellable>()
        
        init(router : TabRouter) {
            super.init()
            
            router.$currentPath.sink { [weak self, weak router] path in
                guard let path = path, let index = router?.paths.firstIndex(of: path) else {
                    return
                }
                
                self?.controller?.selectedIndex = index
            }
            .store(in: &cancellables)
            
            router.didRefresh.sink { [weak self, weak router] action in
                let children : [UIViewController] = (router?.paths ?? []).compactMap {
                    router?.controller(for: $0)
                }
                
                self?.controller?.setViewControllers(children, animated: false)
            }.store(in: &cancellables)
        }
        
        deinit {
            cancellables.forEach {
                $0.cancel()
            }
            
            cancellables.removeAll()
        }
        
    }
    
}
