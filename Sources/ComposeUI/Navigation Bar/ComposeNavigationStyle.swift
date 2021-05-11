import Foundation
import SwiftUI

public struct ComposeNavigationStyle {
    
    public var backgroundColor : Color
    
    public init(backgroundColor : Color = .clear) {
        self.backgroundColor = backgroundColor
    }
    
}

private struct ComposeNavigationStyleKey : EnvironmentKey {
    
    static let defaultValue: ComposeNavigationStyle = ComposeNavigationStyle()
    
}

extension EnvironmentValues {
    
    public var composeNavigationStyle : ComposeNavigationStyle {
        get { self[ComposeNavigationStyleKey.self] }
        set { self[ComposeNavigationStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func composeNavigationStyle(_ style : ComposeNavigationStyle) -> some View {
        self.environment(\.composeNavigationStyle, style)
    }
    
}
