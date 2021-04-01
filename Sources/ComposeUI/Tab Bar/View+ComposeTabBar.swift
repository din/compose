import SwiftUI
import Compose

extension View {
    
    public func composeTabBar<Contents : View>(_ route : Router,
                                               @ComposeTabBarBuilder<Contents> items : @escaping () -> [ComposeTabBarItem<Contents>]) -> some View {
        VStack(spacing: 0) {
            self
            
            ComposeTabBar(route,
                          items: items)
        }
    }
    
}
