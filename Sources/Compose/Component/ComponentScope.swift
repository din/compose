import Foundation
import Combine
import SwiftUI

@dynamicMemberLookup
public class ComponentScope<T : Component> : ObservableObject {
    
    private let component : T
    
    init(component : T) {
        self.component = component
    }
    
    public subscript<V>(dynamicMember keyPath: KeyPath<T, V>) -> V {
        return component[keyPath: keyPath]
    }
    
}
