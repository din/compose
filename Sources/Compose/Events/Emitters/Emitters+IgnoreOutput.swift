import Foundation
import Combine

extension Emitters {
    
    public struct IgnoreOutput : Emitter {
        
        public let id : UUID
        public var publisher: AnyPublisher<Void, Never>
        
        public init<Upstream : Emitter>(emitter : Upstream) {
            self.id = emitter.id
            self.publisher = emitter.publisher
                .map { _ in
                    Void()
                }
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func ignoreOutput() -> Emitters.IgnoreOutput {
        Emitters.IgnoreOutput(emitter: self)
    }
    
}
