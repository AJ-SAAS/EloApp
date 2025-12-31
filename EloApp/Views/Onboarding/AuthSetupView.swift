import SwiftUI

struct AuthSetupView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isCreateAccount = true // Always start on Create Account

    var body: some View {
        VStack(spacing: 30) {

            Text(isCreateAccount ? "Create Account" : "Sign In")
                .font(.largeTitle.bold())
                .padding(.top, 40)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)

            if isCreateAccount {
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
            }

            Button(isCreateAccount ? "Create Account" : "Sign In") {
                handleAuth()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)

            Spacer()
        }
    }

    private func handleAuth() {
        guard !email.isEmpty, !password.isEmpty else { return }

        if isCreateAccount {
            guard password == confirmPassword else {
                // Show error: passwords do not match
                return
            }
            // Call your signup API here
        } else {
            // Sign in API
        }

        // Directly go to home page, no extra progress screen
        // Example: authVM.currentUser = ...
    }
}
