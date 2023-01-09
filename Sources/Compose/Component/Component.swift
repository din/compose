import Foundation
import SwiftUI

public var ComponentAuxiliaryBindableKeyPaths = Set<AnyKeyPath>()

public protocol Component {
    
    var id : UUID { get }
    
    var observers : Void { get }
    
    var view : AnyView { get }
    
}

extension Component {
    
    public var services : Services {
        return Services.all
    }
    
}
