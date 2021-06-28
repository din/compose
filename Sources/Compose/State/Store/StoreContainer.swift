import Foundation
import Combine
import SwiftUI

public class StoreContainer<State : AnyState> : ObservableObject {

    public let willChange = ValueEmitter<State>()

    @Published internal var state : State {
        
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                RefBag.shared.endMonitoring(with: self.updateRefs)
            }
        }
        
    }
    
    internal var cancellables = Set<AnyCancellable>()
    fileprivate var persistStateChangesCancellable : AnyCancellable?
    fileprivate var refCancellables = Set<AnyCancellable>()
    
    fileprivate let storage : AnyPersistentStorage
   
    
    public init(storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        self.storage = storage
        self.state = .init()
        
        $state
            .removeDuplicates()
            .sink { [weak self] state in
            self?.willChange.send(state)
        }.store(in: &cancellables)
        
        DispatchQueue.main.async { [unowned self] in
            RefBag.shared.endMonitoring(with: self.updateRefs)
        }
    }
    
    public func invalidate() {
        self.objectWillChange.send()
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
        
        refCancellables.forEach {
            $0.cancel()
        }
        
        persistStateChangesCancellable?.cancel()
        
        cancellables.removeAll()
        refCancellables.removeAll()
        persistStateChangesCancellable = nil
    }
    
}

extension StoreContainer {
    
    public var binding : Binding<State> {
        .init {
            return self.state
        } set: { value in
            self.state = value
        }
        
    }
    
}

extension StoreContainer where State : Codable {
    
    public func persistStateChanges() {
        guard persistStateChangesCancellable == nil else {
            return
        }
        
        persistStateChangesCancellable = $state
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] state in
                self?.persistence.save()
            }
    }
    
    public var persistence : Persistence<State> {
        .init(storage: storage) {
            return self.state
        } set: { value in
            self.state = value
        }
    }
    
}

extension StoreContainer {
    
    fileprivate func updateRefs(_ refs : [AnyRef]) {
        refCancellables.forEach {
            $0.cancel()
        }
        
        refCancellables.removeAll()

        for ref in refs {
            ref.objectWillChange.sink { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.willChange.send(strongSelf.state)
                strongSelf.objectWillChange.send()
            }.store(in: &refCancellables)
        }
    }
    
}
