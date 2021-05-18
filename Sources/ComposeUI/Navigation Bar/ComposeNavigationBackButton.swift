import Foundation
import SwiftUI
import Compose

public struct ComposeNavigationBackButton : View {
    
    @Environment(\.composeNavigationBarStyle) var style
    @EnvironmentObject var router : Router
    
    let action : (() -> Void)?
    
    init(action : (() -> Void)? = nil) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if let action = action {
                action()
            }
            else {
                router.pop()
            }
        }) {
            ZStack {
                Image(systemName: "chevron.backward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 17, height: 17)
            }
            .frame(width: 25, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}
