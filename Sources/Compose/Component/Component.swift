import Foundation
import SwiftUI

fileprivate var ComponentAuxiliaryBindableKeyPaths = Set<AnyKeyPath>()

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

extension Component {
    
    public static var auxiliaryBindableKeyPaths : Set<AnyKeyPath> {
        get {
            return ComponentAuxiliaryBindableKeyPaths
        }
        
        set {
            ComponentAuxiliaryBindableKeyPaths = newValue
        }
    }
    
}
