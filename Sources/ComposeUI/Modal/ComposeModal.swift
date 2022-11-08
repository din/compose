import Foundation
import SwiftUI

public protocol AnyComposeModal {
    
    var id : UUID { get }
    
    var modalView : AnyView { get }
    
}

public protocol ComposeModal : AnyComposeModal, View {

    
    
}

extension ComposeModal {
    
    public var modalView: AnyView {
        AnyView(self)
    }
    
}
