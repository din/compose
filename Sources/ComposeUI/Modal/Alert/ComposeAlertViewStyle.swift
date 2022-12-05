import Foundation
import SwiftUI

public struct ComposeAlertViewStyle {
    public struct CornerRadius {
        let topLeft : CGFloat
        let topRight : CGFloat
        let bottomLeft : CGFloat
        let bottomRight : CGFloat
        
        public init(topLeft: CGFloat,
                    topRight: CGFloat,
                    bottomLeft: CGFloat,
                    bottomRight: CGFloat) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomLeft = bottomLeft
            self.bottomRight = bottomRight
        }
    }
    
    public var background : AnyView
    
    public var foregroundColor : Color
    public var actionColor : Color
    public var destructiveColor : Color
    public var alertOverlayColor : Color
    public var sheetOverlayColor : Color
    
    public var alertVerticalPadding : CGFloat
    public var alertHorizontalPadding : CGFloat
    public var alertOuterHorizontalPadding : CGFloat
    
    public var sheetVerticalSpacing : CGFloat
    
    public var sheetVerticalPadding : CGFloat
    public var sheetHorizontalPadding : CGFloat
    
    public var alertCornerRadius : CGFloat
    public var sheetCornerRadius : CornerRadius
    
    public var seperatorColor : Color
    
    public init<Background : View>(background : Background = Color.black,
                                   foregroundColor : Color = .white,
                                   actionColor : Color = .blue,
                                   destructiveColor : Color = .red,
                                   alertOverlayColor : Color = Color.black.opacity(0.30),
                                   sheetOverlayColor : Color = Color.black.opacity(0.30),
                                   verticalPadding : CGFloat = 15,
                                   horizontalPadding : CGFloat = 15,
                                   outerHorizontalPadding : CGFloat = 40,
                                   sheetVerticalSpacing : CGFloat = 15,
                                   sheetVerticalPadding : CGFloat = 0,
                                   sheetHorizontalPadding : CGFloat = 15,
                                   alertCornerRadius : CGFloat = 10,
                                   sheetCornerRadius : CornerRadius = .init(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 10),
                                   seperatorColor : Color = Color.white.opacity(0.1)) {
        self.background = AnyView(background)
        self.foregroundColor = foregroundColor
        self.actionColor = actionColor
        self.destructiveColor = destructiveColor
        self.alertOverlayColor = alertOverlayColor
        self.sheetOverlayColor = sheetOverlayColor
        self.alertVerticalPadding = verticalPadding
        self.alertHorizontalPadding = horizontalPadding
        self.alertOuterHorizontalPadding = outerHorizontalPadding
        self.sheetVerticalSpacing = sheetVerticalSpacing
        self.sheetVerticalPadding = sheetVerticalPadding
        self.sheetHorizontalPadding = sheetHorizontalPadding
        self.alertCornerRadius = alertCornerRadius
        self.sheetCornerRadius = sheetCornerRadius
        self.seperatorColor = seperatorColor
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
