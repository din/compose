import Foundation
import Combine

extension Emitters {

    public struct WithCurrent<Upstream : Emitter> : Emitter {
        
        public let id : UUID
        public let publisher: AnyPublisher<Upstream.Value, Never>
        
        public init(emitter : ValueEmitter<Upstream.Value>) {
            self.id = emitter.id
            
            if let lastValue = emitter.lastValue {
                self.publisher = emitter.publisher
                    .prepend(lastValue)
                    .eraseToAnyPublisher()
            }
            else {
                self.publisher = emitter.publisher
                    .eraseToAnyPublisher()
            }
        }
        
    }
    
}

extension Emitter {
    
    public func withCurrent<Value>() -> Emitters.WithCurrent<Self> where Self == ValueEmitter<Value> {
        Emitters.WithCurrent(emitter: self)
    }
    
}
