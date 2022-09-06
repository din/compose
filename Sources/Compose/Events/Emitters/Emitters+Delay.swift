import Foundation
import Combine

extension Emitters {
    
    public struct Delay<Upstream : Emitter, SelectedScheduler : Scheduler> : Emitter {
        
        public let id : UUID
        public var publisher: AnyPublisher<Upstream.Value, Never>
        
        public init(emitter : Upstream,
                    interval : SelectedScheduler.SchedulerTimeType.Stride,
                    scheduler : SelectedScheduler) {
            self.id = emitter.id
            self.publisher = emitter.publisher
                .delay(for: interval, scheduler: scheduler)
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func delay<SelectedScheduler : Scheduler>(interval : SelectedScheduler.SchedulerTimeType.Stride,
                                                     scheduler : SelectedScheduler) -> Emitters.Delay<Self, SelectedScheduler> {
        Emitters.Delay(emitter: self, interval: interval, scheduler: scheduler)
    }
    
    public func delay(interval : RunLoop.SchedulerTimeType.Stride) -> Emitters.Delay<Self, RunLoop> {
        Emitters.Delay(emitter: self, interval: interval, scheduler: RunLoop.main)
    }
    
}
