// Views/Auth/AuthView.swift
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
                    .font(.largeTitle.bold())

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if isCreatingAccount {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button {
                    Task { await handleAction() }   // ← THIS IS THE FIX
                } label: {
                    Group {
                        if authVM.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isCreatingAccount ? "Create Account" : "Sign In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)

                Button {
                    withAnimation { isCreatingAccount.toggle() }
                } label: {
                    Text(isCreatingAccount ?
                         "Already have an account? Sign In" :
                         "Don't have an account? Create one")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    @MainActor
    private func handleAction() async {
        errorMessage = ""

        if isCreatingAccount {
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match"
                return
            }
            guard password.count >= 6 else {
                errorMessage = "Password must be at least 6 characters"
                return
            }

            await authVM.register(email: email, password: password)
        } else {
            await authVM.signIn(email: email, password: password)
        }

        // Show Firebase error if failed
        if let msg = authVM.errorMessage {
            errorMessage = msg
        }
    }
}
