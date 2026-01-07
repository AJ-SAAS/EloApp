import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var rotateLogo = -20.0
    @State private var scaleLogo = 0.5
    @State private var opacity = 1.0
    
    // Get authVM from the app level (injected in EloAppApp)
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            if isActive {
                RootView()
                    .environmentObject(authVM)  // Critical: pass it down!
                    .transition(.opacity)
            }
            
            if !isActive {
                Color.white
                    .ignoresSafeArea()
                
                Image("elologo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: .gray.opacity(0.4), radius: 10)
                    .rotationEffect(.degrees(rotateLogo))
                    .scaleEffect(scaleLogo)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.interpolatingSpring(stiffness: 120, damping: 10)) {
                rotateLogo = 0
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                scaleLogo = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    opacity = 0.0
                    isActive = true
                }
            }
        }
    }
}
