import Foundation

public protocol ValidationNode {
    
}

@_functionBuilder public struct ValidationNodeBuilder {
    
    public static func buildBlock() -> [ValidationNode] {
        return []
    }
    
    public static func buildBlock(_ node : ValidationNode) -> [ValidationNode] {
        return [node]
    }
    
    public static func buildBlock(_ nodes : ValidationNode...) -> [ValidationNode] {
        return nodes
    }
    
}
