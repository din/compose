import Foundation
import Compose
import SwiftUI

@_functionBuilder public struct ComposeTabBarBuilder<Contents : View> {
    
    public static func buildBlock() -> [ComposeTabBarItem<Contents>] {
        return []
    }
    
    public static func buildBlock(_ item : ComposeTabBarItem<Contents>) -> [ComposeTabBarItem<Contents>] {
        return [item]
    }
    
    public static func buildBlock(_ items : ComposeTabBarItem<Contents>...) -> [ComposeTabBarItem<Contents>] {
        return items
    }
    
}

public struct ComposeTabBar<Contents : View> : View {
    
    @Environment(\.composeTabBarStyle) var style
    
    @ObservedObject var route : Router
    
    public let items : [ComposeTabBarItem<Contents>]
    
    public init(_ route : Router, @ComposeTabBarBuilder<Contents> items : () -> [ComposeTabBarItem<Contents>]) {
        self.route = route
        self.items = items()
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            
            Rectangle()
                .overlay(Rectangle()
                            .fill(style.backgroundColor)
                            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100),
                         alignment: .top)
            
            HStack {
                
                Spacer()
                    .frame(width: style.padding)
                
                ForEach(0..<items.count) { index in
                    items[index].opacity(items[index].path == route.path ? 1.0 : 0.4)
                        .foregroundColor(style.foregroundColor)
                        .frame(maxHeight: .infinity)
                        .padding(paddingForItem(at: index))
                        .onTapGesture {
                            guard items[index].path != route.path else {
                                return
                            }
                            
                            route.replace(items[index].path)
                        }
                    
                    if index != items.count - 1 {
                        Spacer()
                    }
                }
                
                Spacer()
                    .frame(width: style.padding)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .padding(.top, 10)
        .frame(minHeight: style.height, maxHeight: style.height)
        .background(style.backgroundColor)
        .overlay(style.shouldShowDivider == true ? Divider() : nil, alignment: .top)
    }
    
    fileprivate func paddingForItem(at index : Int) -> EdgeInsets {
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
