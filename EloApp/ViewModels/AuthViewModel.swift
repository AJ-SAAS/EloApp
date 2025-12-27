import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isSignedIn = false
    @Published var hasEmailAccount = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        startListening()
    }

    private func startListening() {
        handle = FirebaseManager.shared.auth
            .addStateDidChangeListener { [weak self] _, user in

                guard let self else { return }

                self.isSignedIn = user != nil
                self.hasEmailAccount = FirebaseManager.shared.hasEmailProvider
            }
    }

    func register(
        email: String,
        password: String,
        displayName: String
    ) async {

        isLoading = true
        errorMessage = nil

        do {
            try await FirebaseManager.shared.register(
                email: email,
                password: password,
                displayName: displayName
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await FirebaseManager.shared.signIn(
                email: email,
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() {
        try? FirebaseManager.shared.signOut()
    }

    deinit {
        if let handle {
            FirebaseManager.shared.auth
                .removeStateDidChangeListener(handle)
        }
    }
}
