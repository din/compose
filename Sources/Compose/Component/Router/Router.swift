import Foundation
import SwiftUI

public class Router : ObservableObject {
    
    public var path : AnyKeyPath? {
        return paths.last
    }
    
    @Published public fileprivate(set) var paths = [AnyKeyPath]()
    
    var target : Component?
    
    var views : [AnyView] {
        guard paths.count > 0 else {
            return [AnyView(EmptyView())]
        }
        
        let views : [AnyView] = paths.compactMap {
            target[keyPath: $0] as? Component
        }.map {
            if $0.id == target?.id, let component = target as? AnyRoutableView {
                return component.routableView
            }
            else {
                return $0.view
            }
        }
        
        guard views.count > 0 else {
            return [AnyView(EmptyView())]
        }
        
        return views
    }
    
    fileprivate let id = UUID()
    
    public init(start : AnyKeyPath) {
        replace(start)
    }
    
}

extension Router {
    
    public func pop() {
        guard self.paths.count > 0 else {
            return
        }
        
        paths.removeLast()
    }
    
    public func popToRoot() {
        guard paths.count > 0 else {
            return
        }
        
        paths = [paths.first!]
    }
    
    public func push(_ path : AnyKeyPath) {
        self.paths.append(path)
    }
    
    public func replace(_ path : AnyKeyPath) {
        self.paths = [path]
    }
    
}

extension Router : Bindable {
    
    public func bind<C : Component>(to component: C) {
        self.target = component
    }
    
}
