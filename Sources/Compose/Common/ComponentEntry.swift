import Foundation
import SwiftUI
import UIKit
import Combine

public protocol ComponentEntry {
    
    var id : UUID { get }
    
    func didBind()
    
}

extension ComponentEntry {
    
    public func didBind() {
        
    }
    
    var parentController : ComponentController? {
        ComponentControllerStorage.shared.owner(for: self.id)
    }
    
}
