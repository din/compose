import Foundation
import SwiftUI

public struct ComposeShareView : ComposeModal {
    
    private struct ActivityView : UIViewControllerRepresentable {
        
        var activityItems: [Any]
        var applicationActivities: [UIActivity]? = nil
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
            controller.overrideUserInterfaceStyle = .dark
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
            
        }
        
    }
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    public var backgroundBody: some View {
        Color.clear
    }
    
    public var body: some View {
        ActivityView(activityItems: activityItems,
                     applicationActivities: applicationActivities)
    }
    
}
