import Foundation
import Combine

public protocol Emitter {
    associatedtype Value
    
    var id : UUID { get }
    var publisher : AnyPublisher<Value?, Never> { get }
}

extension Emitter {
    
    var cancellableStorage : CancellableStorage {
        Storage.storage(for: \Emitters.self).value(at: id) {
            CancellableStorage()
        }
    }
    
}

extension Emitter {
    
    @discardableResult
    public func observe(handler : @escaping (Value) -> Void) -> AnyCancellable {
        let cancellable = publisher.dropFirst().sink { value in
            guard let value = value else {
                return
            }
            
            handler(value)
        }
        
        cancellableStorage.cancellables.insert(cancellable)
        
        return cancellable
    }
    
    @discardableResult
    public func observeWithLastValue(handler : @escaping (Value) -> Void) -> AnyCancellable  {
        let cancellable = publisher.sink { value in
            guard let value = value else {
                return
            }
            
            handler(value)
        }
        
        cancellableStorage.cancellables.insert(cancellable)
        
        return cancellable
    }
    
    @discardableResult
    public func observeOnce(handler : @escaping (Value) -> Void) -> AnyCancellable {
        var cancellable : AnyCancellable? = nil
        
        cancellable = publisher.dropFirst().sink { value in
            guard let value = value else {
                return
            }
            
            handler(value)
            
            if let cancellable = cancellable {
                cancellableStorage.cancellables.remove(cancellable)
                cancellable.cancel()
            }
        }
        
        if let cancellable = cancellable {
            cancellableStorage.cancellables.insert(cancellable)
        }
        
        return cancellable ?? AnyCancellable({ })
    }
    
}

extension Emitter {
    
    @discardableResult
    public static func +=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        return lhs.observe(handler: rhs)
    }
    
    @discardableResult
    public static func ++=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        return lhs.observeWithLastValue(handler: rhs)
    }
    
    @discardableResult
    public static func !+=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        return lhs.observeOnce(handler: rhs)
    }
    
}
