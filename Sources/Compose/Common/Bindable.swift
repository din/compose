import Foundation

public protocol Bindable : class {
    
    func bind<C : Component>(to component : C)
    
}
