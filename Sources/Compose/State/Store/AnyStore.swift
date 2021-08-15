import Foundation

protocol AnyStore {
    
    var id : UUID { get }
    
    var willChange : AnyEmitter { get }
    
    var isMapped : Bool { get }
    
}
