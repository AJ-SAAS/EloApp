import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = true

    var body: some View {
        VStack(spacing: 20) {

            // Hero Title – Apple font applied
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.system(.largeTitle, design: .default).weight(.bold))
                .padding(.bottom, 40)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

            if isSignUp {
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }

            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

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
            }
        }
    }

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
                }

            } else {
                _ = await authVM.signIn(email: email, password: password)
            }
        }
    }
}
