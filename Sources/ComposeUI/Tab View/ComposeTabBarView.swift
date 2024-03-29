import Foundation
import SwiftUI

public struct ComposeTabBarView : View {
    
    @Environment(\.composeTabViewStyle) fileprivate var style
    @Environment(\.composeTabBarViewRepeatedAction) fileprivate var repeatedAction
    
    public let items : [ComposeTabItem]
    @Binding var selectedItemId : AnyHashable?
    
    public init(selectedItemId : Binding<AnyHashable?>,
                @ComposeTabViewBuilder items : () -> [ComposeTabItem]) {
        self.items = items()
        self._selectedItemId = selectedItemId
    }
    
    public init(selectedItemId : Binding<AnyHashable?>,
                items : [ComposeTabItem]) {
        self.items = items
        self._selectedItemId = selectedItemId
    }
    
    public var body : some View {
        ZStack(alignment: .top) {
            
            Rectangle()
                .fill(.clear)
                .overlay(Rectangle()
                            .fill(.clear)
                            .frame(maxWidth: .infinity, minHeight: style.backgroundHeight, maxHeight: style.backgroundHeight)
                            .background(style.background),
                         alignment: .top)
            
            HStack {
                
                ForEach(items) { item in
                    item.itemContent
                        .foregroundColor(item.id == selectedItemId ? style.tintColor : style.foregroundColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard selectedItemId != item.id else {
                                repeatedAction?()
                                return
                            }
                            
                            selectedItemId = item.id
                        }
                }
                .frame(maxHeight: .infinity)
                
            }
            .padding(.horizontal, style.padding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .frame(minHeight: style.height, maxHeight: style.height)
        .overlay(style.shouldShowDivider == true ? Divider() : nil, alignment: .top)
    }
    
}
