import Foundation
import Combine

extension Emitters {
    
    public struct Debounce<Value, SelectedScheduler : Scheduler> : Emitter {
        
        public let id = UUID()
        public var publisher: AnyPublisher<Value?, Never>
        
        public init<Upstream : Emitter>(emitter : Upstream,
                                        interval : SelectedScheduler.SchedulerTimeType.Stride,
                                        scheduler : SelectedScheduler) where Upstream.Value == Value {
            self.publisher = emitter.publisher
                .debounce(for: interval, scheduler: scheduler)
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func debounce<SelectedScheduler : Scheduler>(interval : SelectedScheduler.SchedulerTimeType.Stride,
                                                        scheduler : SelectedScheduler) -> Emitters.Debounce<Value, SelectedScheduler> {
        Emitters.Debounce(emitter: self, interval: interval, scheduler: scheduler)
    }
    
    public func debounce(interval : RunLoop.SchedulerTimeType.Stride) -> Emitters.Debounce<Value, RunLoop> {
        Emitters.Debounce(emitter: self, interval: interval, scheduler: RunLoop.main)
    }
    
}
