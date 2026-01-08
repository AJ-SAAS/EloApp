import SwiftUI
import Firebase
import FirebaseAuth
import RevenueCat

@main
struct EloAppApp: App {

    // MARK: - StateObjects for environment
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var purchaseVM = PurchaseViewModel() // new

    init() {
        FirebaseApp.configure()
        
        // Configure RevenueCat SDK
        Purchases.configure(withAPIKey: "appl_dJDZHvEwwSlXdvdMOVnlmgUXcRq")
        
        // Log in to RevenueCat if user already signed in
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
            // Root view
            SplashView()
                .environmentObject(authVM)
                .environmentObject(purchaseVM) // inject PurchaseViewModel globally
                .preferredColorScheme(.light)   // force light mode
        }
    }
}
