import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var progress = ProgressTracker.shared
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                splashScreen
            } else {
                mainContent
            }
        }
        .animation(.easeInOut, value: showSplash)
    }

    // MARK: - Splash Screen
    private var splashScreen: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Image("elologo")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .cornerRadius(36)
                .rotationEffect(.degrees(showSplash ? -15 : 0))
                .scaleEffect(showSplash ? 0.8 : 1.2)
                .opacity(showSplash ? 0 : 1)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8)) {
                        // Tilt → straighten → fade in
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)) {
                            showSplash = false
                        }
                    }
                }
        }
    }

    // MARK: - Main App Content
    private var mainContent: some View {
        Group {
            // ✅ Fully authenticated user
            if authVM.isSignedIn && authVM.hasEmailAccount {
                MainTabView()
            }
            // ⛔ Signed in but missing email provider
            else if authVM.isSignedIn {
                NavigationStack {
                    AuthView()
                }
            }
            // ❌ Not signed in
            else {
                if progress.onboardingCompleted {
                    NavigationStack {
                        AuthView()
                    }
                } else {
                    OnboardingContainerView()
                }
            }
        }
    }
}
