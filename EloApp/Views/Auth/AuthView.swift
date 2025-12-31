import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = true // ✅ Always start on Create Account

    var body: some View {
        VStack(spacing: 20) {

            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.largeTitle.bold())
                .padding(.bottom, 40)

            // Email Field
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

            // Password Field
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

            // Confirm Password for Sign Up
            if isSignUp {
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }

            // Error message
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            // Auth Button
            Button(action: handleAuth) {
                Text(isSignUp ? "Sign Up" : "Sign In")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
            }
            .disabled(isSignUp && password != confirmPassword)

            // Toggle Sign In / Sign Up
            Button {
                isSignUp.toggle()
            } label: {
                Text(isSignUp
                     ? "Already have an account? Sign In"
                     : "Don't have an account? Sign Up")
            }
            .foregroundColor(.blue)

            Spacer()
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
        .navigationTitle(isSignUp ? "Sign Up" : "Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if authVM.isLoading {
                ProgressView()
                    .scaleEffect(1.0) // ✅ Remove zoom glitch
            }
        }
    }

    // MARK: - Handle Auth Logic
    private func handleAuth() {
        Task {
            if isSignUp {
                guard password == confirmPassword else {
                    authVM.errorMessage = "Passwords do not match"
                    return
                }

                let success = await authVM.register(email: email, password: password)
                if success {
                    authVM.completeOnboarding()
                    authVM.isSignedIn = true // ✅ Immediately mark signed in
                }

            } else {
                let success = await authVM.signIn(email: email, password: password)
                if success {
                    authVM.isSignedIn = true
                }
            }
        }
    }
}
