import Foundation
import FirebaseAuth
import Combine
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var isSignedIn = false
    @Published var hasEmailAccount = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        startListening()
    }

    // MARK: - Auth Listener
    private func startListening() {
        handle = Auth.auth()
            .addStateDidChangeListener { [weak self] _, user in
                guard let self else { return }
                self.isSignedIn = user != nil
                self.hasEmailAccount = user?.providerData.contains {
                    $0.providerID == EmailAuthProviderID
                } ?? false
            }
    }

    // MARK: - ✅ REQUIRED BY VIEWS (DO NOT REMOVE)
    func completeOnboarding() {
        ProgressTracker.shared.markOnboardingCompleted()
    }

    var userEmail: String? {
        Auth.auth().currentUser?.email
    }

    // MARK: - Auth Actions
    func register(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Logout
    func signOut() {
        do {
            try Auth.auth().signOut()
            ProgressTracker.shared.resetOnboarding()
        } catch {
            print("Sign out failed:", error.localizedDescription)
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
