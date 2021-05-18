import Foundation
import SwiftUI

public struct ComposeTabViewStyle {
    
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

private struct ComposeTabViewStyleKey : EnvironmentKey {
    
    static let defaultValue: ComposeTabViewStyle = ComposeTabViewStyle()
    
}

extension EnvironmentValues {
    
    public var composeTabViewStyle : ComposeTabViewStyle {
        get { self[ComposeTabViewStyleKey.self] }
        set { self[ComposeTabViewStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func composeTabViewStyle(_ style : ComposeTabViewStyle) -> some View {
        self.environment(\.composeTabViewStyle, style)
    }
    
}
