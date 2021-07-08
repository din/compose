import Foundation
import Compose
import SwiftUI

public struct ComposeTabItem : Identifiable {
    
    public let id : AnyHashable
    public let view : AnyView
    public let itemContent : AnyView
    
    public init<ItemContent : View>(_ component : Component, @ViewBuilder itemContent : () -> ItemContent) {
        self.id = component.id
        self.view = component.view
        self.itemContent = AnyView(itemContent())
    }
    
    public init<ItemContent : View>(id : AnyHashable, @ViewBuilder itemContent : () -> ItemContent) {
        self.id = id
        self.view = AnyView(EmptyView())
        self.itemContent = AnyView(itemContent())
    }
    
}
