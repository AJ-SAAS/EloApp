import Foundation
import FirebaseAuth
import FirebaseFirestore
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

    // MARK: - Auth State Listener
    private func startListening() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }

            self.isSignedIn = user != nil
            self.hasEmailAccount =
                user?.providerData.contains(where: { $0.providerID == EmailAuthProviderID }) ?? false

            if self.isSignedIn && !ProgressTracker.shared.onboardingCompleted {
                ProgressTracker.shared.markOnboardingCompleted()
            }
        }
    }

    // MARK: - User Info
    var userEmail: String? {
        Auth.auth().currentUser?.email
    }

    var currentUserUID: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - Email Auth (USED BY AuthView)
    func register(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await Auth.auth()
                .createUser(withEmail: email, password: password)

            print("✅ Registered user:", result.user.uid)
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
            let result = try await Auth.auth()
                .signIn(withEmail: email, password: password)

            print("✅ Signed in user:", result.user.uid)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("👋 Signed out")
        } catch {
            print("❌ Sign out failed:", error.localizedDescription)
        }
    }

    // MARK: - Delete Account (Apple-compliant re-auth)
    func deleteAccount(
        password: String? = nil,
        onReAuthRequired: (() -> Void)? = nil
    ) async {

        guard let user = Auth.auth().currentUser else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Re-auth if password provided
            if let password,
               let email = user.email {
                let credential = EmailAuthProvider.credential(
                    withEmail: email,
                    password: password
                )
                try await user.reauthenticate(with: credential)
            }

            // Delete Firestore user document
            try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .delete()

            // Delete Auth user
            try await user.delete()

            print("🔥 Account permanently deleted")

        } catch let error as NSError {
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                onReAuthRequired?()
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Onboarding
    func completeOnboarding() {
        ProgressTracker.shared.markOnboardingCompleted()
    }

    // MARK: - Cleanup
    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
