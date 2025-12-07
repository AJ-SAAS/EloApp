import SwiftUI
import Combine   // ✅ Needed for ObservableObject & @Published
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    func listenToAuthState() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isSignedIn = (user != nil)
        }
    }

    func register(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("✅ Signed up:", result.user.email ?? "")
            isSignedIn = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ Signed in:", result.user.email ?? "")
            isSignedIn = true
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func signOut() async {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
