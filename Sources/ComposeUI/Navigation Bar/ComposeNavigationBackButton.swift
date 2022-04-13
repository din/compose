#if os(iOS)

import Foundation
import SwiftUI
import Compose

public struct ComposeNavigationBackButton : View {
    
    @Environment(\.composeNavigationBarStyle) var style
    
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
                    .padding(.leading, -8)
                    .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 0)
                    .font(.system(size: 16, weight: .semibold, design: .default))
            }
            .frame(width: 25, alignment: .leading)
            .padding(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}

struct ComposeNavigationBackButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            VStack {
                Text("Navigation styles")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .composeNavigationBar(title: "Example", backButtonEmitter: SignalEmitter())
            .composeNavigationBarStyle(.init(foregroundColor: .white))
        }
        .preferredColorScheme(.dark)
    }
}

#endif
