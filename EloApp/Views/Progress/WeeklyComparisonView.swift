import SwiftUI

struct WeeklyComparisonView: View {

    let percentChange: Int

    var body: some View {
        HStack {
            Image(systemName: percentChange >= 0 ? "arrow.up" : "arrow.down")
                .foregroundColor(percentChange >= 0 ? .green : .red)

            Text(
                percentChange >= 0
                ? "+\(percentChange)% vs last week"
                : "\(percentChange)% vs last week"
            )
            .font(.headline)

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
