//
//  File.swift
//  
//
//  Created by Daniel Vershinin on 08.01.2021.
//

import Foundation

public protocol AnyValidation {
    init()
}

extension AnyValidation {

    mutating func validate(object: Any) {
        //TODO: make this executed once only.
        let mirror = Mirror(reflecting: self)
        
        for (_, value) in mirror.children {
            if let value = value as? Validator {
                value.validate(object: object)
            }
        }
    }
    
}
