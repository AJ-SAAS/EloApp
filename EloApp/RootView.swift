import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isSignedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }
    }
}
