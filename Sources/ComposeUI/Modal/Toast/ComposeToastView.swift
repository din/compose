#if os(iOS)

import Foundation
import SwiftUI
import Combine

public struct ComposeToastView : ComposeModal {
    @Environment(\.composeToastViewStyle) private var style
    @EnvironmentObject private var manager : ComposeModalManager
    @State private var timerCancellable : AnyCancellable? = nil

    public let title : LocalizedStringKey
    public let message : LocalizedStringKey
    public let event : ComposeToastViewEvent
    
    public init(title: LocalizedStringKey, message: LocalizedStringKey, event: ComposeToastViewEvent = .normal) {
        self.title = title
        self.message = message
        self.event = event
    }
    
    public var backgroundBody: some View {
        EmptyView()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .default))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
                .frame(height: 4)
            
            Text(message)
                .font(.system(size: 15, weight: .regular, design: .default))
                .lineSpacing(-6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundColor(style.foregroundColor)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black)
            RoundedRectangle(cornerRadius: 10)
                .fill(style.color(for: event))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        })
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor.separator).opacity(0.3))
        )
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .transition(
            AnyTransition.move(edge: .top)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.95))
        )
        .onAppear {
            timerCancellable = Timer.publish(every: 3.0, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    timerCancellable?.cancel()
                    manager.dismiss()
                }
        }
        .onTapGesture {
            timerCancellable?.cancel()
            manager.dismiss()
        }
    }
    
}

struct ComposeToastView_Previews: PreviewProvider {
    
    static var toast : some View {
        ComposeToastView(title: "Generic message",
                         message: "This is neither good nor bad. Figure out what to do with this.")
        .composeToastViewStyle(
            ComposeToastViewStyle(backgroundColor: Color.blue,
                                  foregroundColor: Color.white)
        )
    }
    
    static var successToast : some View {
        ComposeToastView(title: "Very good",
                         message: "Something very good happened. And this is good news!",
                         event: .success)
            .composeToastViewStyle(
                ComposeToastViewStyle(backgroundColor: Color.blue,
                                      foregroundColor: Color.white)
            )
    }
    
    static var errorToast : some View {
        ComposeToastView(title: "Network error",
                         message: "Something bad happened with network during the request. Try again!",
                         event: .error)
            .composeToastViewStyle(
                ComposeToastViewStyle(backgroundColor: Color.blue,
                                      foregroundColor: Color.white)
            )
    }
    
    static var previews: some View {
        Group {
            VStack {
                Spacer()
                toast
                Spacer()
                successToast
                Spacer()
                errorToast
                Spacer()
            }
            .preferredColorScheme(.dark)
            
            VStack {
                Spacer()
                toast
                Spacer()
                successToast
                Spacer()
                errorToast
                Spacer()
            }
        }
        .background(Color.white.opacity(0.1))
    }
}

#endif
