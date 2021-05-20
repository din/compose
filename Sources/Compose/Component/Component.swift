import Foundation
import SwiftUI

public protocol Component {
    
    static var auxiliaryBindableKeyPaths : [AnyKeyPath] { get }
    
    var id : UUID { get }
    
    var observers : Void { get }
    
    var view : AnyView { get }
    
}

extension Component {
    
    public static var auxiliaryBindableKeyPaths : [AnyKeyPath] {
        []
    }
    
}

extension Component {
    
    static var Name : String {
        return String(describing: self)
    }
    
}

extension Component {
    
    public var services : Services {
        return Services.all
    }
    
}

