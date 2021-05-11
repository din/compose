import Foundation

public protocol ValidatorNode {
    
}

@resultBuilder public struct ValidatorNodeBuilder {
    
    public static func buildBlock() -> [ValidatorNode] {
        return []
    }
    
    public static func buildBlock(_ node : ValidatorNode) -> [ValidatorNode] {
        return [node]
    }
    
    public static func buildBlock(_ nodes : ValidatorNode...) -> [ValidatorNode] {
        return nodes
    }
    
}
