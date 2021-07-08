import Foundation
import SwiftUI

@resultBuilder public struct ComposeTabViewBuilder {
    
    public static func buildBlock() -> [ComposeTabItem] {
        return []
    }
    
    public static func buildBlock(_ item : ComposeTabItem) -> [ComposeTabItem] {
        return [item]
    }
    
    public static func buildBlock(_ items : ComposeTabItem...) -> [ComposeTabItem] {
        return items
    }
    
}

public struct ComposeTabView : View {
    
    public let items : [ComposeTabItem]
    
    @Environment(\.composeTabViewStyle) fileprivate var style
    @State fileprivate var currentId : AnyHashable? = nil
    
    public init(@ComposeTabViewBuilder items : () -> [ComposeTabItem]) {
        self.items = items()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(items) { item in
                    item.view
                        .opacity(item.id == currentId ? 1.0 : 0.0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ComposeTabBarView(selectedItemId: $currentId, items: items)
        }
        .onAppear {
            self.currentId = self.items.first?.id
        }
    }
    
}

extension ComposeTabView {
    
    private func paddingForItem(at index : Int) -> EdgeInsets {
        if index == 0 {
            return .init(top: 0, leading: 0, bottom: 0, trailing: 15)
        }
        else if index == items.indices.last {
            return .init(top: 0, leading: 15, bottom: 0, trailing: 0)
        }
        else {
            return .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        }
    }
    
}
