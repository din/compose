import Foundation
import SwiftUI

public protocol AnyComposeModal {
    
    var backgroundView : AnyView { get }
    var modalView : AnyView { get }
    
}

public protocol ComposeModal : AnyComposeModal, View {
    associatedtype BackgroundBody : View
    
    var backgroundBody : BackgroundBody { get }
    
}

extension ComposeModal {
    
    public var backgroundView: AnyView {
        AnyView(self.backgroundBody)
    }
    
    public var modalView: AnyView {
        AnyView(self)
    }
    
}
