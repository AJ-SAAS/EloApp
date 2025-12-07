import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var isCreatingAccount = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Text(isCreatingAccount ? "Create Account" : "Sign In")
                    .font(.largeTitle)
                    .bold()

                // MARK: - Email Field
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)

                // MARK: - Password Field
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                // MARK: - Confirm Password (Sign Up Only)
                if isCreatingAccount {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                }

                // MARK: - Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

                // MARK: - Main Button
                Button(action: handleAction) {
                    Text(isCreatingAccount ? "Create Account" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                // MARK: - Switch Mode
                Button {
                    withAnimation {
                        isCreatingAccount.toggle()
                    }
                } label: {
                    Text(isCreatingAccount ?
                         "Already have an account? Sign In" :
                         "Don't have an account? Create one")
                        .font(.subheadline)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Action Handler
    private func handleAction() {
        Task {
            errorMessage = ""

            if isCreatingAccount {
                // Validate
                guard password == confirmPassword else {
                    errorMessage = "Passwords do not match"
                    return
                }
                guard password.count >= 6 else {
                    errorMessage = "Password must be at least 6 characters"
                    return
                }

                do {
                    try await authVM.register(email: email, password: password)
                } catch {
                    errorMessage = error.localizedDescription
                }

            } else {
                // Login
                do {
                    try await authVM.signIn(email: email, password: password)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
