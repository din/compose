import Foundation
import Compose
import SwiftUI

public struct ComposeTabBarItem<Contents : View> : View, Identifiable {
    
    public let path : AnyKeyPath
    public let id: ObjectIdentifier
    
    let contents : Contents
    
    public init(_ path : AnyKeyPath, @ViewBuilder contents : () -> Contents) {
        self.path = path
        self.id = ObjectIdentifier(path)
        self.contents = contents()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            contents
        }
    }
    
}
