import Foundation
import SwiftUI

public struct ComposeTabBarView : View {
    
    @Environment(\.composeTabViewStyle) fileprivate var style
    
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
                .overlay(Rectangle()
                            .fill(style.backgroundColor)
                            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100),
                         alignment: .top)
            
            HStack {
                
                ForEach(items) { item in
                    item.itemContent
                        .foregroundColor(item.id == selectedItemId ? style.tintColor : style.foregroundColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItemId = item.id
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
    
}
