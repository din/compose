import Foundation
import Combine

extension Emitters {
  
    public struct Undup<Upstream : Emitter> : Emitter where Upstream.Value : Equatable {
        
        public let id = UUID()
        public let publisher: AnyPublisher<Upstream.Value?, Never>
        
        public init(emitter : Upstream) {
            self.publisher = emitter.publisher
                .removeDuplicates()
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {

    public func undup() -> Emitters.Undup<Self> where Self.Value : Equatable {
        Emitters.Undup(emitter: self)
    }
    
}
