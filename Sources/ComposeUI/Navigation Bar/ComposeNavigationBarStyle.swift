import Foundation
import SwiftUI

public struct ComposeNavigationBarStyle {
    
    public var backgroundColor : Color
    public var foregroundColor : Color
    public var tintColor : Color
    
    public var height : CGFloat
    public var padding : CGFloat
    
    public init(backgroundColor : Color = .black,
                foregroundColor : Color = .white,
                tintColor : Color = .blue,
                height : CGFloat = 60,
                padding : CGFloat = 30) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.tintColor = tintColor
        self.height = height
        self.padding = padding
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

