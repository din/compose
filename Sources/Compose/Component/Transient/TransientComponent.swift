import Foundation
import SwiftUI

struct TransientComponent<Content : View> : Component {
    
    let content : Content
    
    var observers: Void {
        None
    }
    
    var view: AnyView {
        AnyView(content)
    }
    
}
