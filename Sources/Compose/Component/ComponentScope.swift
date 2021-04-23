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

@propertyWrapper public class ComponentScopeObject<T : Component> : ObservableObject {
    
    public var wrappedValue : ComponentScope<T>? {
        return Storage.storage(for: \Component.self).value(at: path) as? ComponentScope<T>
    }
    
    fileprivate let path : AnyKeyPath
    
    public init(_ path : PartialKeyPath<T>) {
        self.path = path
    }
    
}
