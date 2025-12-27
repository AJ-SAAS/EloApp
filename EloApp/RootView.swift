import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {

            // ✅ Fully authenticated user
            if authVM.isSignedIn && authVM.hasEmailAccount {
                MainTabView()
            }

            // ⛔ Signed in (anonymous / cached) but no email yet
            else if authVM.isSignedIn {
                AuthView()
                    .environmentObject(authVM)
            }

            // ❌ Not signed in at all
            else {
                if ProgressTracker.shared.isOnboardingCompleted {
                    AuthView()
                        .environmentObject(authVM)
                } else {
                    SplashView()
                        .environmentObject(authVM)
                }
            }
        }
    }
}
