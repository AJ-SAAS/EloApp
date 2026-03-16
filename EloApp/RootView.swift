import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    // Shared singleton for progress flags (streak, etc.)
    @StateObject private var progress = ProgressTracker.shared
    
    // Shared view model for UI progress display
    @StateObject private var progressVM = ProgressViewModel()

    var body: some View {
        Group {

            // ✅ Fully authenticated → Main App
            if authVM.isSignedIn && authVM.hasEmailAccount {
                MainTabView()
                    .environmentObject(progressVM)
            }

            // ⛔ Signed in but no email linked
            else if authVM.isSignedIn {
                NavigationStack {
                    AuthView()
                        .environmentObject(authVM)
                }
            }

            // ❌ Not signed in
            else {

                // Onboarding already completed → Auth
                if progress.onboardingCompleted {
                    NavigationStack {
                        AuthView()
                            .environmentObject(authVM)
                    }
                }

                // First time user → Onboarding
                else {
                    OnboardingContainerView()
                        .environmentObject(authVM)
                }
            }
        }
        .onAppear {
            progressVM.load()
        }
    }
}
