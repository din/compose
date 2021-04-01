import Foundation
import SwiftUI

public struct ComposeAlertViewStyle {
    
    public var backgroundColor : Color
    public var foregroundColor : Color
    public var actionColor : Color
    public var destructiveColor : Color
    public var overlayColor : Color
    
    public var verticalPadding : CGFloat
    public var horizontalPadding : CGFloat
    
    public var outerHorizontalPadding : CGFloat
    
    public init(backgroundColor : Color = .black,
                foregroundColor : Color = .white,
                actionColor : Color = .blue,
                destructiveColor : Color = .red,
                overlayColor : Color = Color.black.opacity(0.85),
                verticalPadding : CGFloat = 15,
                horizontalPadding : CGFloat = 15,
                outerHorizontalPadding : CGFloat = 40) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.actionColor = actionColor
        self.destructiveColor = destructiveColor
        self.overlayColor = overlayColor
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.outerHorizontalPadding = outerHorizontalPadding
    }
    
}

private struct ComposeAlertViewStyleKey : EnvironmentKey {
    
    static let defaultValue: ComposeAlertViewStyle = ComposeAlertViewStyle()
    
}

extension EnvironmentValues {
    
    public var composeAlertViewStyle : ComposeAlertViewStyle {
        get { self[ComposeAlertViewStyleKey.self] }
        set { self[ComposeAlertViewStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func composeAlertViewStyle(_ style : ComposeAlertViewStyle) -> some View {
        self.environment(\.composeAlertViewStyle, style)
    }
    
}
