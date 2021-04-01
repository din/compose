import Foundation
import SwiftUI

public protocol ComposeModalPresentable : View {
    associatedtype BackgroundBody : View
    
    var background : BackgroundBody { get }
    
}
