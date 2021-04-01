import Foundation
import SwiftUI

struct ComposeModalPresenter : Identifiable {
    
    let id = UUID()
    
    let view : AnyView
    let background : AnyView
    
}
