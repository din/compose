import Foundation

public protocol AnyPersistentStorage : AnyObject {
    
    var key : String { get }
    
    init(key : String)
    
    func save<State : Codable>(state : State)
    func restore<State : Codable>() -> State?
    func purge()
}
