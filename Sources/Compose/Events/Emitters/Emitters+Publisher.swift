import Foundation
import Combine

extension Emitters {
    
    public struct PublisherEmitter<Upstream : Publisher> : Emitter {
        public typealias Value = Result<Upstream.Output, Upstream.Failure>
        
        public let id = UUID()
        public let publisher: AnyPublisher<Value, Never>
        
        public init(publisher : Upstream) {
            self.publisher = publisher
                .flatMap { output in
                    Just(Value.success(output))
                        .setFailureType(to: Upstream.Failure.self)
                }
                .catch { error -> AnyPublisher<Value, Never> in
                    Just(Value.failure(error))
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Publisher {
    
    public func emitter() -> Emitters.PublisherEmitter<Self> {
        Emitters.PublisherEmitter(publisher: self)
    }
    
}
