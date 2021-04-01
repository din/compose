import Foundation
import SwiftUI

public protocol AnyRoutableView {
    
    var routableView : AnyView { get }
    
}

public protocol RoutableView : AnyRoutableView, View {
    associatedtype RoutableBody : View
    
    var routableBody : RoutableBody { get }
}

extension RoutableView {
    
    public var routableView: AnyView {
        AnyView(routableBody)
    }
    
}
