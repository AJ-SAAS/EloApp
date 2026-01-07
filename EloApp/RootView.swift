import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    // Shared singleton for basic progress flags (streak, etc.)
    @StateObject private var progress = ProgressTracker.shared
    
    // Shared view model for UI progress display
    @StateObject private var progressVM = ProgressViewModel()

    var body: some View {
        Group {
            // ✅ Fully authenticated: go to main app
            if authVM.isSignedIn && authVM.hasEmailAccount {
                MainTabView()
                    .environmentObject(progressVM)
            }
            // ⛔ Signed in but no email linked (e.g., Apple sign-in only)
            else if authVM.isSignedIn {
                NavigationStack {
                    AuthView()
                }
            }
            // ❌ Not signed in at all
            else {
                if ProgressTracker.shared.onboardingCompleted {
                    // Onboarding done before → go to sign in/up
                    NavigationStack {
                        AuthView()
                            .environmentObject(authVM)
                    }
                } else {
                    // First time user → show onboarding
                    OnboardingContainerView()
                        .environmentObject(authVM)  // Critical: paywall needs authVM!
                }
            }
        }
        // Optional: Refresh progress data when view appears
        .onAppear {
            progressVM.load()  // Ensures latest XP, streak, etc.
        }
    }
}
