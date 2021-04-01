import Foundation
import Combine

@frozen public struct Emitters {
    
}

extension Emitters {
    
    public struct Merge<T> {
        
        let emitters : [Emitter<T>]
        
        public init(_ emitters : Emitter<T>...) {
            assert(emitters.count > 1, "Emitters.Merge must have at least two emitters to merge their results.")
            
            self.emitters = emitters
        }
        
        public static func +=(lhs : Self, rhs : @escaping (T) -> Void) {
            Publishers.MergeMany(lhs.emitters.map { $0.publisher.dropFirst() })
                .compactMap { $0 }
                .sink(receiveValue: rhs)
                .store(in: &lhs.emitters[0].sinks)
        }
        
        static func ++=<T>(lhs : Self, rhs : @escaping (T) -> Void) {
            Publishers.MergeMany(lhs.emitters.map { $0.publisher })
                .compactMap { $0 as? T }
                .sink(receiveValue: rhs)
                .store(in: &lhs.emitters[0].sinks)
        }
        
    }
    
}

public typealias EmitterList<T> = (Emitter<T>, Emitter<T>)
public typealias EmitterList3<T> = (Emitter<T>, Emitter<T>, Emitter<T>)
public typealias EmitterList4<T> = (Emitter<T>, Emitter<T>, Emitter<T>, Emitter<T>)

public func +=<T>(lhs : EmitterList<T>, rhs: @escaping (T) -> Void) {
    Emitters.Merge(lhs.0, lhs.1) += rhs
}

public func +=<T>(lhs : EmitterList3<T>, rhs: @escaping (T) -> Void) {
    Emitters.Merge(lhs.0, lhs.1, lhs.2) += rhs
}

public func +=<T>(lhs : EmitterList4<T>, rhs: @escaping (T) -> Void) {
    Emitters.Merge(lhs.0, lhs.1, lhs.2, lhs.3) += rhs
}

public func ++=<T>(lhs : EmitterList<T>, rhs: @escaping (T) -> Void) {
    Emitters.Merge(lhs.0, lhs.1) ++= rhs
}

public func ++=<T>(lhs : EmitterList3<T>, rhs: @escaping (T) -> Void) {
    Emitters.Merge(lhs.0, lhs.1, lhs.2) ++= rhs
}

public func ++=<T>(lhs : EmitterList4<T>, rhs: @escaping (T) -> Void) {
    Emitters.Merge(lhs.0, lhs.1, lhs.2, lhs.3) ++= rhs
}
