import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var rotateLogo = -20.0
    @State private var scaleLogo = 0.5
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            Image("elologo")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 5)
                .rotationEffect(.degrees(rotateLogo))
                .scaleEffect(scaleLogo)
                .animation(.interpolatingSpring(stiffness: 120, damping: 10), value: rotateLogo)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: scaleLogo)
        }
        .onAppear {
            // Tilt straightening + pop effect
            withAnimation(.interpolatingSpring(stiffness: 120, damping: 10)) {
                rotateLogo = 0
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                scaleLogo = 1.0
            }
            
            // Navigate to onboarding after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            OnboardingContainerView()
        }
    }
}
