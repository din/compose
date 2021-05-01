import Foundation
import Combine

extension Emitters {
    
    public struct Debounce<Upstream : Emitter, SelectedScheduler : Scheduler> : Emitter {
        
        public let id = UUID()
        public var publisher: AnyPublisher<Upstream.Value, Never>
        
        public init(emitter : Upstream,
                    interval : SelectedScheduler.SchedulerTimeType.Stride,
                    scheduler : SelectedScheduler) {
            self.publisher = emitter.publisher
                .debounce(for: interval, scheduler: scheduler)
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func debounce<SelectedScheduler : Scheduler>(interval : SelectedScheduler.SchedulerTimeType.Stride,
                                                        scheduler : SelectedScheduler) -> Emitters.Debounce<Self, SelectedScheduler> {
        Emitters.Debounce(emitter: self, interval: interval, scheduler: scheduler)
    }
    
    public func debounce(interval : RunLoop.SchedulerTimeType.Stride) -> Emitters.Debounce<Self, RunLoop> {
        Emitters.Debounce(emitter: self, interval: interval, scheduler: RunLoop.main)
    }
    
}
