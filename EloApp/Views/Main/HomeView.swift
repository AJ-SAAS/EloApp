import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    var body: some View {
        DailyWordView()
            .environmentObject(authVM)       // pass AuthViewModel
            .environmentObject(purchaseVM)   // pass PurchaseViewModel
            .navigationBarHidden(true)
    }
}
