import Foundation
import SwiftUI

public struct TransientComponent : Component {
    
    public let content : AnyView
    
    public init<Content : View>(content: Content) {
        self.content = AnyView(content)
    }
    
    public var observers: Void {
        None
    }
    
    public var view: AnyView {
        content
    }
    
}
