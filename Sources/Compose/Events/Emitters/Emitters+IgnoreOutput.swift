import Foundation
import Combine

extension Emitters {
    
    public struct IgnoreOutput<Upstream : Emitter> : Emitter {
        
        public let id = UUID()
        public var publisher: AnyPublisher<Void, Never>
        
        public init(emitter : Upstream) {
            self.publisher = emitter.publisher
                .map { _ in
                    Void()
                }
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func ignoreOutput() -> Emitters.IgnoreOutput<Self> {
        Emitters.IgnoreOutput(emitter: self)
    }
    
}
