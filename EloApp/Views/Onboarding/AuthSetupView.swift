// Views/Onboarding/AuthSetupView.swift

import SwiftUI

struct AuthSetupView: View {
    @ObservedObject var vm: OnboardingViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)

            Text("Hi \(vm.userName.isEmpty ? "" : vm.userName.capitalized),")
                .font(.largeTitle.bold())

            Text("Let's finish your setup!")
                .font(.title2)

            Text("Create an account to save your progress.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Continue with Email") {
                completeOnboarding()
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Already have an account? Log in") {
                completeOnboarding()
            }
            .foregroundColor(.blue)

            Spacer()
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
    }

    // MARK: - Helpers

    private func completeOnboarding() {
        ProgressTracker.shared.markOnboardingCompleted()

        // IMPORTANT:
        // Do NOT dismiss or navigate manually.
        // RootView will automatically show AuthView
        // because user is not signed in.
    }
}
