import Foundation

public protocol Bindable {
    
    func bind<C : Component>(to component : C)
    
}
