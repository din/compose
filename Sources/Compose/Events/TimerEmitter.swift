import Foundation
import Combine

public class TimerEmitter : Emitter {
    
    public let id = UUID()

    public var publisher: AnyPublisher<Date, Never> {
        timerPublisher.eraseToAnyPublisher()
    }
    
    fileprivate let timerPublisher : Timer.TimerPublisher
    
    deinit {
        stop()
    }
    
    public init(every interval: TimeInterval, on runloop: RunLoop = RunLoop.main, in mode: RunLoop.Mode = .default) {
        self.timerPublisher = Timer.publish(every: interval, on: runloop, in: mode)
    }
    
    public func start(_ handler : @escaping (Date) -> Void) {
        let observer = Observer<Date>(action: handler)
     
        self.timerPublisher
            .autoconnect()
            .subscribe(observer)
        
        self.parentController?.addObserver(observer, for: self.id)
    }
    
    public func stop() {
        self.parentController?.removeObserver(for: self.id)
    }
    
}
