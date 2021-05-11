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
    
    public func push(_ keyPath : AnyKeyPath, animated : Bool = true) {
        guard animated == true else {
            self.paths.append(keyPath)
            self.didPush.send(keyPath)
            return
        }
        
        withAnimation(.easeOut(duration: 0.28)) {
            self.paths.append(keyPath)
            self.pushPath = keyPath
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.29) { [weak self] in
            self?.pushPath = nil
            self?.didPush.send(keyPath)
        }
    }
    
    public func pop(animated : Bool = true) {
        guard self.paths.count > 0 else {
            return
        }
        
        let change = { [weak self] in
            guard let self = self else {
                return
            }
            
            let path = self.paths.removeLast()
            
            if let component = self.target[keyPath: path] as? AnyDynamicComponent {
                component.destroy()
            }
            
            self.didPop.send(path)
        }
        
        guard animated == true else {
            change()
            return
        }

        withAnimation(.easeOut(duration: 0.25)) {
            change()
        }
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
