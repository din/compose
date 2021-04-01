import Foundation

prefix operator ~

extension KeyPath {
    
    public static prefix func ~(_ keyPath : KeyPath) -> AnyKeyPath {
        return keyPath as AnyKeyPath
    }
    
}
