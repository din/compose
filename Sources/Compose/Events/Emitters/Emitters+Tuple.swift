import Foundation
import Combine

//extension Emitters {
//    
//    public struct Tuple<First : Emitter, Second : Emitter> : Emitter {
//        
//        public let id = UUID()
//        public var publisher: AnyPublisher<(First.Value, Second.Value), Never>
//        
//        public let upstreamIds : [UUID]
//        
//        public init(first : First, second : Second) {
//            self.publisher = first.publisher
//                .combineLatest(second.publisher)
//                .eraseToAnyPublisher()
//            self.upstreamIds = [first.id, second.id]
//        }
//        
//    }
//    
//}
//
//extension Emitter {
//    
//    func tuple<Second : Emitter>(with emitter : Second) -> Emitters.Tuple<Self, Second> {
//        Emitters.Tuple(first: self, second: emitter)
//    }
//    
//}
