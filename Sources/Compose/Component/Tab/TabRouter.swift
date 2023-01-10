import Foundation
import SwiftUI
import UIKit

public class TabRouter : ObservableObject, ComponentEntry {
    
    public let id = UUID()
    
    @Published var paths = [AnyKeyPath]()
    @Published public var currentPath : AnyKeyPath? = nil
    
    public init(paths : [AnyKeyPath]) {
        self.paths = paths
        self.currentPath = paths.first
    }
    
}

extension TabRouter {
    
    public func update(paths : [AnyKeyPath]) {
        self.paths = paths
        self.currentPath = paths.first
    }
    
}

extension TabRouter {
    
    func controller(for keyPath : AnyKeyPath) -> ComponentController? {
        guard let target = parentController?.component else {
            print("[CCR] Warning: tab router is unbound. No components could be looked up.")
            return nil
        }
        
        guard let component = target[keyPath: keyPath] as? Component else {
            print("[CCR] Warning: tab router is unable to find component under keypath: '\(keyPath)'.")
            return nil
        }
        
        if let dynamicComponent = component as? AnyDynamicComponent, let controller = dynamicComponent.storage.lastController {
            return controller
        }
        else {
            return component.controller
        }
    }
    
}
