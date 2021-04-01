//
//  File.swift
//  
//
//  Created by Daniel Vershinin on 18.11.2020.
//

import Foundation
import Combine

struct EmitterObserver<T> : Equatable, Hashable {
 
    let id = CombineIdentifier()
    
    static func == (lhs: EmitterObserver<T>, rhs: EmitterObserver<T>) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var handler : ((T) -> Void)? = nil
    var changeHandler : ((T, T) -> Void)? = nil
    
    init(handler : @escaping (T) -> Void) {
        self.handler = handler
    }
    
    init(changeHandler : @escaping (T, T) -> Void) {
        self.changeHandler = changeHandler
    }
    
}
