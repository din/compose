import Foundation
import SwiftUI

public protocol RouterComponent : Component {
    associatedtype RouterType : Router
    
    var router : RouterType { get }
}

extension RouterComponent {
    
    public var view: AnyView {
        return AnyView(
            lifecycle(RouterView().environmentObject(router))
        )
    }
    
}

extension RouterComponent where Self : View {
    
    public var view: AnyView {
        return AnyView(
            lifecycle(self.environmentObject(router))
        )
    }
    
}
