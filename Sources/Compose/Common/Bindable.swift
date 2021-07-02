import Foundation

public protocol Bindable {
    
    func bind<C : Component>(to component : C)
    
}

protocol BindableObject : AnyObject, Bindable {
    
    func unbind()
    
}
