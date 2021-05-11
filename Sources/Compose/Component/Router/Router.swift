import Foundation
import SwiftUI

public final class Router : ObservableObject {
    
    public var path : AnyKeyPath? {
        paths.last
    }
    
    @Published public var paths = [AnyKeyPath]()
        
    public let didPush = ValueEmitter<AnyKeyPath>()
    public let didPop = ValueEmitter<AnyKeyPath>()
    public let didReplace = ValueEmitter<AnyKeyPath>()
    
    internal var target : Component?
    internal let options : RouterOptions

    @Published internal var pushPath : AnyKeyPath? = nil

    internal let reader = AnimationReader()
    internal let id = UUID()
    
    fileprivate let start : AnyKeyPath?
    
    public init(start : AnyKeyPath, options : RouterOptions = .init()) {
        self.start = start
        self.options = options
        replace(start)
    }
    
    public init(options : RouterOptions = .init()) {
        self.start = nil
        self.options = options
    }
    
}

extension Router {
    
    public func push(_ keyPath : AnyKeyPath) {
        self.pushPath = keyPath

        reader.read { value in
            guard value >= 1.0 else {
                return
            }
            
            self.pushPath = nil
        }
        
        self.paths.append(keyPath)

        didPush.send(keyPath)
    }
    
    public func pop() {
        guard self.paths.count > 0 else {
            return
        }

        let path = paths.removeLast()
   
        if let component = self.target[keyPath: path] as? AnyDynamicComponent {
            component.destroy()
        }
        
        didPop.send(path)
    }
    
    public func popToRoot() {
        guard self.paths.count > 0 else {
            return
        }
        
        if let start = start {
            paths = [start]
        }
        else {
            paths = []
        }
    }
    
    public func replace(_ keyPath : AnyKeyPath) {
        self.paths = [keyPath]
        
        didReplace.send(keyPath)
    }
    
}

extension Router : Bindable {
    
    public func bind<C : Component>(to component: C) {
        self.target = component
        
        Storage.shared.setValue(self, at: Storage.RouterObjectKey(id: \C.self))
    }
    
}
