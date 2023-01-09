import Foundation
import SwiftUI

public struct TransientComponent<Content : View> : Component {
    
    public let content : Content
    
    public init(content: Content) {
        self.content = content
    }
    
    public var observers: Void {
        None
    }
    
    public var view: AnyView {
        AnyView(content)
    }
    
}
