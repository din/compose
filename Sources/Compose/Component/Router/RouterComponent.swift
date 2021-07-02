import Foundation
import SwiftUI

public protocol RouterComponent : Component {
    var router : Router { get }
}

extension RouterComponent {
    
    public var view: AnyView {
        return AnyView(
            lifecycle(RouterView(router))
        )
    }
    
}

extension RouterComponent where Self : View {
    
    public var view: AnyView {
        return AnyView(
            lifecycle(self)
        )
    }
    
}
