import Foundation
import SwiftUI
import Compose

struct ComposeNavigationBackButton : View {
    
    @Environment(\.composeNavigationBarStyle) var style
    
    let action : () -> Void
    
    init(emitter : SignalEmitter) {
        self.init {
            emitter.send()
        }
    }
    
    init(action : @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.backward")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 17, height: 17)
        }
        .foregroundColor(style.tintColor)
        .buttonStyle(PlainButtonStyle())
    }
    
}
