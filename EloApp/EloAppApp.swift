import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct EloAppApp: App {
    @StateObject private var authVM = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isSignedIn {
                    MainTabView()
                } else {
                    AuthView()
                }
            }
            .environmentObject(authVM)
        }
    }
}
