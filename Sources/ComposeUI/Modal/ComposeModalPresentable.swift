import Foundation
import SwiftUI

public protocol ComposeModalPresentable : View {
    associatedtype BackgroundBody : View
    
    var background : BackgroundBody { get }
    
}

extension ComposeModalPresentable {
    
    public static func toast(title : String,
                             message : String,
                             event : ComposeToastViewEvent = .normal) -> ComposeToastView {
        .init(title: title, message: message, event: event)
    }
    
    public static func alert(title : String,
                             message : String,
                             @ComposeAlertActionBuilder actions : () -> [ComposeAlertAction]) -> ComposeAlertView {
        .init(title: title, message: message, actions: actions)
    }
    
}
