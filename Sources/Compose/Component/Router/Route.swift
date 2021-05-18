import Foundation
import SwiftUI

struct Route : Identifiable, Equatable {
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.id == rhs.id
    }
    
    let id : UUID
    let view : AnyView
    let path : AnyKeyPath
    let zIndex : Double
}
