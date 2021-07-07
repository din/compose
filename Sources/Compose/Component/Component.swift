import Foundation
import SwiftUI

public protocol Component {
    
    static var auxiliaryBindableKeyPaths : [AnyKeyPath] { get }
    
    var type : Component.Type { get }
    
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
    
    public var type : Component.Type {
        return Self.self
    }
    
}

extension Component {
    
    public var services : Services {
        return Services.all
    }
    
}

