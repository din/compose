import Foundation
import Combine

extension Emitters {
    
    public struct Erase<T> : Emitter {
        
        public let id : UUID
        public var publisher: AnyPublisher<T, Never>
        
        public init<Upstream : Emitter>(emitter : Upstream) where Upstream.Value == T {
            self.id = emitter.id
            self.publisher = emitter.publisher
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func erase<T>(to type : T.Type) -> Emitters.Erase<T> where Self.Value == T {
        Emitters.Erase(emitter: self)
    }
    
}
