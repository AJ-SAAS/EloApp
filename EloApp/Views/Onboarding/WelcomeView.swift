import SwiftUI

struct WelcomeView: View {
    let vm: OnboardingViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to Elo!")
                    .font(.system(size: 48, weight: .bold))
                    .multilineTextAlignment(.leading)

                Text("Boost your language skills with Elo effortlessly anytime, anywhere.")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal)

            Spacer().frame(height: 60)

            VStack(spacing: 16) {

                // ✅ LOGIN BUTTON (not Text)
                Button("Log in") {
                    authVM.completeOnboarding()
                }
                .font(.title3.bold())
                .foregroundColor(.blue)

                Button("Let's Go") {
                    vm.nextPage()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal)

            Spacer().frame(height: 40)
        }
        .padding()
    }
}
