import Foundation
import SwiftUI

public struct ComposeTabBarStyle {
    
    public var backgroundColor : Color
    public var foregroundColor : Color
    public var tintColor : Color
    
    public var height : CGFloat
    public var padding : CGFloat
    
    public var shouldShowDivider : Bool
    
    public init(backgroundColor : Color = .black,
                foregroundColor : Color = .white,
                tintColor : Color = .blue,
                height : CGFloat = 40,
                padding : CGFloat = -16,
                shouldShowDivider : Bool = true) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.tintColor = tintColor
        self.height = height
        self.padding = padding
        self.shouldShowDivider = shouldShowDivider
    }

    
}

private struct ComposeTabBarStyleKey : EnvironmentKey {
    
    static let defaultValue: ComposeTabBarStyle = ComposeTabBarStyle()
    
}

extension EnvironmentValues {
    
    public var composeTabBarStyle : ComposeTabBarStyle {
        get { self[ComposeTabBarStyleKey.self] }
        set { self[ComposeTabBarStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func composeTabBarStyle(_ style : ComposeTabBarStyle) -> some View {
        self.environment(\.composeTabBarStyle, style)
    }
    
}
