import Foundation
import SwiftUI
import Compose

public struct ComposeNavigationBackButton : View {
    
    let action : () -> Void
    
    public init(emitter : SignalEmitter) {
        self.init {
            emitter.send()
        }
    }
    
    init(action : @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
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
