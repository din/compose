import Foundation
import Combine
import SwiftUI

public class StoreContainer<State : AnyState> : ObservableObject {

    public let willChange = ValueEmitter<State>()

    @Published internal var state : State
    
    internal var cancellables = Set<AnyCancellable>()
    
    fileprivate let storage : AnyPersistentStorage
    fileprivate var persistStateChangesCancellable : AnyCancellable?
    
    public init(storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        self.state = .init()
        self.storage = storage
        
        $state
            .removeDuplicates()
            .sink { [weak self] state in
            self?.willChange.send(state)
        }.store(in: &cancellables)
        
        let mirror = Mirror(reflecting: state)
        
        for child in mirror.children {
            guard let value = child.value as? AnyRef else {
                continue
            }
            
            value.objectWillChange.sink { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.willChange.send(strongSelf.state)
                strongSelf.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }
    
    public func invalidate() {
        self.objectWillChange.send()
    }
    
    deinit {
        cancellables.removeAll()
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
