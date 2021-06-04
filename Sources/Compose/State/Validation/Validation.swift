import Foundation

@resultBuilder public struct ValidationBuilder {
    
    public static func buildBlock() -> [AnyField] {
        []
    }
    
    public static func buildBlock(_ component : AnyField) -> [AnyField] {
        [component]
    }
    
    public static func buildBlock(_ components: [AnyField]...) -> [AnyField] {
        components.flatMap { $0 }
    }
    
    public static func buildFinalResult(_ components: [AnyField]) -> Validation {
        Validation(components)
    }
    
    public static func buildExpression<T>(_ expression: Field<T>) -> [AnyField] {
        [expression]
    }

    public static func buildExpression<T>(_ expression: ArrayField<T>) -> [AnyField] {
        [expression]
    }
    
}

@frozen public struct Validation {
    
    public let isValid : Bool
    public let errors : [String]
    
    public init(_ fields : [AnyField]) {
        isValid = fields.allSatisfy { $0.isValid }
        errors = fields.flatMap { $0.errors }
    }
    
}
