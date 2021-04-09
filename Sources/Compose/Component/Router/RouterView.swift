import Foundation
import SwiftUI

public struct RouterView : View, Identifiable {
    
    @EnvironmentObject var router : Router
    
    ///Identifier on a router view allows us to switch between similar nested router views inside other router views.
    ///Without an identifiers, SwiftUI wouldn't replace a view inside a `ForEach` statement because they would be identical to SwiftUI.
    public let id = UUID()

    public var body: some View {
        ZStack(alignment: .top) {
            ForEach(router.views.indices, id: \.self) { index in
                router.views[index]
                    .opacity(router.paths.count == 1 || index == router.views.count - 1 ? 1.0 : 0.0)
            }
        }
    }
    
    public init() {
        
    }
    
}
