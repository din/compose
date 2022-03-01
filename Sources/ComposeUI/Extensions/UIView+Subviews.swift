#if os(iOS)

import Foundation
import UIKit

extension UIView {
    
    func subviews<T : UIView>(ofType WhatType : T.Type) -> [T] {
        var result = self.subviews.compactMap {$0 as? T}
        
        for sub in self.subviews {
            result.append(contentsOf: sub.subviews(ofType:WhatType))
        }
        
        return result
    }
    
    func ancestor<T : UIView>(ofType type: T.Type) -> T? {
        var superview = self.superview
        
        while let s = superview {
            if let typed = s as? T {
                return typed
            }
            
            superview = s.superview
        }
        
        return nil
    }
    
}

#endif
