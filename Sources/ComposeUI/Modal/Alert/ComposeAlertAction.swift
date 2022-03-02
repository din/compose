import Foundation
import SwiftUI

public protocol ComposeAlertActionGroup {
    
    var actions : [ComposeAlertAction] { get }
    
}

extension ComposeAlertAction : ComposeAlertActionGroup {
   
    public var actions: [ComposeAlertAction] {
        [self]
    }
    
}

extension Array: ComposeAlertActionGroup where Element == ComposeAlertAction {
  
    public var actions: [ComposeAlertAction] {
        self
    }
    
}

@resultBuilder public struct ComposeAlertActionBuilder {
    
    public static func buildBlock() -> [ComposeAlertAction] {
        []
    }
    
    public static func buildBlock(_ action : ComposeAlertAction) -> [ComposeAlertAction] {
        [action]
    }
    
    public static func buildBlock(_ actions: ComposeAlertActionGroup...) -> [ComposeAlertAction] {
        actions.flatMap { $0.actions }
    }
    
    public static func buildEither(first action: [ComposeAlertAction]) -> [ComposeAlertAction] {
        action
    }
    
    public static func buildEither(second action: [ComposeAlertAction]) -> [ComposeAlertAction] {
        action
    }
    
    public static func buildOptional(_ actions: [ComposeAlertActionGroup]?) -> [ComposeAlertAction] {
        actions?.flatMap { $0.actions } ?? []
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
    
    public init(title : LocalizedStringKey, kind : Kind = .normal, handler : @escaping () -> Void = {}) {
        self.content = AnyView(Text(title))
        
        self.kind = kind
        self.handler = handler
    }
    
}
