import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                NavigationLink("Daily Word", destination: DailyWordView())
                    .buttonStyle(.borderedProminent)

            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
