import SwiftUI

@propertyWrapper public struct EnclosingRouter {

    public var wrappedValue : Router {
        router
    }

    let router = Router()

    public init() {

    }

}

extension EnclosingRouter {

    public class Router {

        fileprivate var router : Compose.Router? {
            guard let id = componentId else {
                return nil
            }

            return Introspection.shared.descriptor(forComponent: id)?.runtimeEnclosingRouter
        }

        fileprivate var componentId : UUID? = nil

        public func push<T : Component, V>(_ keyPath : KeyPath<T, V>, animated : Bool = true) {
            guard let id = componentId, let descriptor = Introspection.shared.descriptor(forComponent: id) else {
                return
            }

            guard let enclosingPath = router?.paths.last else {
                return
            }

            var path : AnyKeyPath = keyPath

            if descriptor.lifecycle == .dynamic {
                path = \DynamicComponent<T>.[dynamicMember: keyPath]
            }
            else if descriptor.lifecycle == .instance {
                path = \InstanceComponent<T>.[dynamicMember: keyPath]
            }

            guard let path = enclosingPath.appending(path: path) else {
                print("[EnclosingRouter] Invalid keypath to push to the router.")
                return
            }
            
            router?.push(path, animated: animated)
        }

        public func pop(animated : Bool = true) {
            router?.pop(animated: animated)
        }

    }

}

extension EnclosingRouter : Bindable {

    public func bind<C>(to component: C) where C : Component {
        router.componentId = component.id
    }

}
