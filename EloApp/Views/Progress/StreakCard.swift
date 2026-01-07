import SwiftUI

struct StreakCard: View {

    let currentStreak: Int
    let weekly: [Int: Bool]

    let days = ["S","M","T","W","T","F","S"]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Daily Streak")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    Text("\(currentStreak) Days")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                }

                Spacer()

                Image(systemName: "flame.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }

            HStack(spacing: 10) {
                ForEach(1...7, id: \.self) { i in
                    VStack {
                        Circle()
                            .fill(weekly[i] == true ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 22, height: 22)
                        Text(days[i-1])
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.green, .mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(22)
    }
}
