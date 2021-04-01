import Foundation
import SwiftUI

public protocol Component {
    
    var view : AnyView { get }
    
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

