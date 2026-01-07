import SwiftUI

struct MainTabView: View {
    // Receive the injected ProgressViewModel
    @EnvironmentObject var progressVM: ProgressViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Today", systemImage: "flame.fill")
                }

            ProgressScreen()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        // Optional: re-inject if any child view creates a new context (rare, but safe)
        .environmentObject(progressVM)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(ProgressViewModel())  // For preview only
}
