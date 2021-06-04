import Foundation

infix operator !~= : SetBooleanComparisonPrecedence

precedencegroup SetBooleanComparisonPrecedence {
    higherThan: LogicalConjunctionPrecedence
    associativity: left
    assignment: false
}

public typealias StatusSet<S : AnyStatus> = Set<S>

extension StatusSet {
    
    public static func +=(lhs : inout Set<Element>, rhs : Element) {
        lhs.insert(rhs)
    }
    
    public static func -=(lhs : inout Set<Element>, rhs : Element) {
        lhs.remove(rhs)
    }
    
    public static func |=(lhs : inout Set<Element>, rhs : Element) {
        lhs.removeAll()
        lhs.insert(rhs)
    }
    
    public static func ~=(lhs : Set<Element>, rhs : Element) -> Bool {
        lhs.contains(rhs)
    }
    
    public static func !~=(lhs : Set<Element>, rhs : Element) -> Bool {
        lhs.contains(rhs) == false
    }
    
}
