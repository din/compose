import Foundation
import SwiftUI

extension Component where Self : View {
    
    public var view: AnyView {
        let scope = ComponentScope(component: self)
 
        return AnyView(
            lifecycle(self.environmentObject(scope))
        )
    }
    
}
