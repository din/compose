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
    @State fileprivate var currentId : UUID? = nil
    
    public init(@ComposeTabViewBuilder items : () -> [ComposeTabItem]) {
        self.items = items()
    }
    
    public var body: some View {
        VStack {
            ZStack {
                ForEach(items) { item in
                    item.view
                        .opacity(item.id == currentId ? 1.0 : 0.0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            tabBarBody
        }
        .onAppear {
            self.currentId = self.items.first?.id
        }
    }
    
}

extension ComposeTabView {
    
    var tabBarBody : some View {
        ZStack(alignment: .top) {
            
            Rectangle()
                .overlay(Rectangle()
                            .fill(style.backgroundColor)
                            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100),
                         alignment: .top)
            
            HStack {
                
                ForEach(items) { item in
                    item.itemContent
                        .opacity(item.id == currentId ? 1.0 : 0.4)
                        .foregroundColor(item.id == currentId ? style.tintColor : style.foregroundColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard item.id != currentId else {
                                return
                            }
                            
                            currentId = item.id
                        }
                }
                .frame(maxHeight: .infinity)
                
            }
            .padding(.horizontal, style.padding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .padding(.top, 10)
        .frame(minHeight: style.height, maxHeight: style.height)
        .background(style.backgroundColor)
        .overlay(style.shouldShowDivider == true ? Divider() : nil, alignment: .top)
    }
    
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
