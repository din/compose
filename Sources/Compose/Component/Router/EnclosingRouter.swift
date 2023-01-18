import SwiftUI
import Combine

@propertyWrapper public struct EnclosingRouter : ComponentEntry {

    public var wrappedValue : Router {
        router
    }
    
    public var projectedValue : EnclosingRouter {
        self
    }

    public var id : UUID {
        router.id
    }
    
    let router = Router()
  
    public init() {

    }

}

extension EnclosingRouter {

    public class Router {
        
        fileprivate let id = UUID()

        fileprivate var router : Compose.Router? {
            guard let controller = ComponentControllerStorage.shared.owner(for: id) else {
                return nil
            }
            
            guard let navigationController = controller.navigationController as? RouterNavigationController else {
                return nil
            }

            return navigationController.router
        }
        
        fileprivate var tabRouter : Compose.TabRouter? {
            guard let controller = ComponentControllerStorage.shared.owner(for: id) else {
                return nil
            }
            
            guard let tabController = controller.tabBarController as? TabBarController else {
                return nil
            }
            
            return tabController.router
        }

        public func push<T : Component, V>(_ keyPath : KeyPath<T, V>, animated : Bool = true) {
            let enclosingPaths = Array(router?.paths.reversed() ?? [])
            
//             TODO: figure out how to push through tab bar controllers.
//            if let path = tabRouter?.currentPath {
//                enclosingPaths.append(path)
//            }
            
            for enclosingPath in enclosingPaths {
                var path : AnyKeyPath = keyPath
                
                if enclosingPath.appending(path: path) == nil {
                    path = \DynamicComponent<T>.[dynamicMember: keyPath]
                }
                
                guard let fullPath = enclosingPath.appending(path: path) else {
                    continue
                }
                
                router?.push(fullPath, animated: animated)
                return
            }
            
        
            print("[Compose] Invalid keypath to push to the enclosing router.")
        }
        
        public func pop(animated : Bool = true) {
            router?.pop(animated: animated)
        }
        
    }
    
}
