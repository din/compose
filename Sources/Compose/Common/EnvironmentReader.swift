import Foundation
import SwiftUI
import Combine

struct EnvironmentReader : UIViewRepresentable {
    
    let id : UUID
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.alpha = 0.0
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        ComponentControllerStorage.shared.environmentValues[self.id] = context.environment
    }
    
}

/*struct EnvironmentReader : View {
    

    @Environment(\.self) var environmentValues
    
    let id : UUID
    
    var body: some View {
        EmptyView()
            .onAppear {
                ComponentControllerStorage.shared.environmentValues[self.id] = environmentValues
            }
    }
    
}*/
