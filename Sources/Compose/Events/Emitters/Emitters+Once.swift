import Foundation
import Combine

extension Emitters {
    
    public struct Once<Upstream : Emitter> : Emitter {
        
        public let id : UUID
        public let publisher: AnyPublisher<Upstream.Value, Never>
        
        public init(emitter : Upstream) {
            self.id = emitter.id
            self.publisher = emitter.publisher
                .first()
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func once() -> Emitters.Once<Self> {
        Emitters.Once(emitter: self)
    }
    
    @discardableResult
    public static func !+=(lhs : Self, rhs : @escaping (Value) -> Void) -> AnyCancellable {
        lhs.once().observe(handler: rhs)
    }
    
}
