import Foundation
import SwiftUI

public struct ComposeFieldGroup<Content : View> : View {
    
    @StateObject private var context = ComposeFieldGroupContext()
    
    private let shouldFocusFirstField : Bool
    private let content : (ComposeFieldGroupContext) -> Content
    
    public init(shouldFocusFirstField : Bool = true,
         @ViewBuilder content : @escaping (ComposeFieldGroupContext) -> Content) {
        self.shouldFocusFirstField = shouldFocusFirstField
        self.content = content
    }
    
    public var body: some View {
        content(context)
            .background(ComposeFieldGroupDetector(context: context, shouldFocusFirstField: shouldFocusFirstField))
    }
    
}

public class ComposeFieldGroupContext : ObservableObject {
    
    public var current : String = "" {
        
        didSet {
            guard let field = fields.object(forKey: current as NSString) else {
                return
            }
            
            field.becomeFirstResponder()
        }
        
    }
    
    fileprivate let fields = NSMapTable<NSString, UITextField>.strongToWeakObjects()
    
}

fileprivate struct ComposeFieldGroupDetector : UIViewRepresentable {
    
    let context : ComposeFieldGroupContext
    let shouldFocusFirstField : Bool
    
    @State private var count : Int = 0
    
    func makeUIView(context viewContext: Context) -> some UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            guard let container = uiView.superview?.superview else {
                return
            }
            
            guard self.count == 0 else {
                return
            }
            
            let foundFields = container.subviews(ofType: UITextField.self)
            
            for field in foundFields {
                guard let name = field.placeholder else {
                    return
                }
                
                self.context.fields.setObject(field, forKey: name as NSString)
            }
            
            self.count = foundFields.count
            
            if shouldFocusFirstField == true {
                foundFields.first?.becomeFirstResponder()
            }
        }
    }
    
}

