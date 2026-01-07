import SwiftUI
import Firebase
import FirebaseAuth
import RevenueCat

@main
struct EloAppApp: App {

    // Keep the AuthViewModel as environment object for the rest of the app
    @StateObject private var authVM = AuthViewModel()

    init() {
        FirebaseApp.configure()
        
        // Configure RevenueCat SDK
        Purchases.configure(withAPIKey: "appl_dJDZHvEwwSlXdvdMOVnlmgUXcRq")
        
        // If user is already signed in with Firebase, log them in to RevenueCat
        if let user = Auth.auth().currentUser {
            Task {
                do {
                    let customerInfo = try await Purchases.shared.logIn(user.uid)
                    print("RevenueCat logged in for user:", user.uid)
                    print("Customer Info:", customerInfo)
                } catch {
                    print("RevenueCat logIn error:", error.localizedDescription)
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            // Start with the animated splash screen
            SplashView()
                // Pass the authVM down through the hierarchy
                .environmentObject(authVM)
        }
    }
}
