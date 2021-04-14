import Foundation
import Combine
import SwiftUI

public typealias ValidatedStore<State : AnyState, Validation : AnyValidation> = Store<State, Validation, Empty>
public typealias IndicatedStore<State : AnyState, Status : AnyStatus> = Store<State, Empty, Status>
public typealias PlainStore<State : AnyState> = Store<State, Empty, Empty>

public class Store<State : AnyState,
                   Validation : AnyValidation,
                   Status : AnyStatus> : AnyStore, ObservableObject {
    
    @Published public var state : State
    
    @Published public var status : Set<Status> = []
    
    @Published public var validation = Validation()
    
    public let didChange : Emitter<State>

    public let didStatusChange : Emitter<Set<Status>>
    
    var cancellables = Set<AnyCancellable>()
    
    fileprivate let storage : AnyPersistentStorage
    
    public init(_ initialState : State = .init(), storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        self.state = initialState
        self.didChange = Emitter(initialState)
        self.didStatusChange = Emitter([])
        self.storage = storage
        
        $state
            .removeDuplicates()
            .sink { state in
            self.didChange.send(state)
        }.store(in: &cancellables)
        
        $state
            .dropFirst()
            .removeDuplicates()
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { state in
            self.validation.validate(object: state)
        }.store(in: &cancellables)
        
        $status
            .sink { status in
            self.didStatusChange.send(status)
        }.store(in: &cancellables)
    }
    
    public func invalidate() {
        self.objectWillChange.send()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
}

extension Store {
    
    public var binding : Binding<State> {
        .init {
            return self.state
        } set: { value in
            self.state = value
        }
        
    }
    
}

extension Store {
    
    public var persistence : Persistence<State> {
        .init(storage: storage) {
            return self.state
        } set: { value in
            self.state = value
        }
    }
    
}
