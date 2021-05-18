import Foundation
import Combine

import Foundation
import Combine

extension Emitters {
    
    public struct MapErrorToNilEmitter<Upstream : Emitter, Value, Error> : Emitter where Upstream.Value == Result<Value, Error> {
        
        public let id = UUID()
        public let publisher: AnyPublisher<Value?, Never>
        
        public init(emitter : Upstream) {
            self.publisher = emitter.publisher
                .flatMap { output -> AnyPublisher<Value?, Never> in
                    switch output {
                    
                    case .failure(_):
                        return Just(nil)
                            .eraseToAnyPublisher()
                        
                    case .success(let value):
                        return Just(value)
                            .eraseToAnyPublisher()
                        
                    }
                }
                .eraseToAnyPublisher()
        }
    }
    
}

extension Emitter {
    
    public func mapErrorToNil<Value, Error>() -> Emitters.MapErrorToNilEmitter<Self, Value, Error> where Self.Value == Result<Value, Error> {
        Emitters.MapErrorToNilEmitter(emitter: self)
    }
    
}
