import Foundation

public protocol Bindable : AnyObject {
    
    func bind<C : Component>(to component : C)
    
}
