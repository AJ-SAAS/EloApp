import SwiftUI

struct HomeView: View {
    var body: some View {
        DailyWordView() // This is now your entire home screen
            .navigationBarHidden(true)
    }
}
