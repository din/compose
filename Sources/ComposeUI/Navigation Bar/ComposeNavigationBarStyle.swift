import Foundation
import SwiftUI

public struct ComposeNavigationBarStyle {
    
    public var backgroundColor : Color
    public var foregroundColor : Color
    public var tintColor : Color
    
    public var height : CGFloat
    public var horizontalPadding : CGFloat
    
    public var shouldShowDivider : Bool
    
    public var alwaysCenterTitle : Bool
    
    public var normalFont : Font
    public var largeFont : Font

    
    public init(backgroundColor : Color = .clear,
                foregroundColor : Color = .clear,
                tintColor : Color = .blue,
                height : CGFloat = 44,
                horizontalPadding : CGFloat = 24,
                shouldShowDivider : Bool = false,
                alwaysCenterTitle : Bool = false,
                normalFont : Font = .system(size: 16, weight: .semibold, design: .default),
                largeFont: Font = .system(size: 18, weight: .regular)) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.tintColor = tintColor
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.shouldShowDivider = shouldShowDivider
        self.alwaysCenterTitle = alwaysCenterTitle
        self.normalFont = normalFont
        self.largeFont = largeFont
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

