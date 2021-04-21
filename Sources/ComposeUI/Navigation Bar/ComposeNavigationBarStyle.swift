import Foundation
import SwiftUI

public struct ComposeNavigationBarStyle {
    
    public var backgroundColor : Color
    public var foregroundColor : Color
    public var tintColor : Color
    
    public var height : CGFloat
    public var horizontalPadding : CGFloat
    
    public var shouldShowDivider : Bool
    
    public init(backgroundColor : Color = .clear,
                foregroundColor : Color = .black,
                tintColor : Color = .blue,
                height : CGFloat = 44,
                horizontalPadding : CGFloat = 24,
                shouldShowDivider : Bool = false) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.tintColor = tintColor
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.shouldShowDivider = shouldShowDivider
    }

}

private struct ComposeNavigationBarStyleKey : EnvironmentKey {
    
    static let defaultValue: ComposeNavigationBarStyle = ComposeNavigationBarStyle()
    
}

extension EnvironmentValues {
    
    public var composeNavigationBarStyle : ComposeNavigationBarStyle {
        get { self[ComposeNavigationBarStyleKey.self] }
        set { self[ComposeNavigationBarStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func composeNavigationBarStyle(_ style : ComposeNavigationBarStyle) -> some View {
        self.environment(\.composeNavigationBarStyle, style)
    }
    
}

