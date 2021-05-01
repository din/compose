import Foundation
import SwiftUI

extension Component where Self : View {
    
    public var view: AnyView {
        return AnyView(
            lifecycle(self)
        )
    }
    
}
