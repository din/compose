import Foundation
import SwiftUI

@resultBuilder public struct ComposeAlertActionBuilder {
    
    public static func buildBlock() -> [ComposeAlertAction] {
        return []
    }
    
    public static func buildBlock(_ action : ComposeAlertAction) -> [ComposeAlertAction] {
        return [action]
    }
    
    public static func buildBlock(_ actions : ComposeAlertAction...) -> [ComposeAlertAction] {
        return actions
    }
    
}

public struct ComposeAlertAction : Identifiable, Equatable {
    
    public enum Kind {
        case normal
        case destructive
    }
    
    public static func == (lhs: ComposeAlertAction, rhs: ComposeAlertAction) -> Bool {
        lhs.id == rhs.id
    }
    
    public let content : AnyView
    public let kind : Kind
    public let handler : () -> Void
    
    public let id = UUID()
    
    public init<Content : View>(@ViewBuilder content : () -> Content) {
        self.content = AnyView(content())
        self.kind = .normal
        self.handler = {}
    }
    
    public init(title : String, kind : Kind = .normal, handler : @escaping () -> Void = {}) {
        self.content = AnyView(Text(title))
        self.kind = kind
        self.handler = handler
    }
    
}
