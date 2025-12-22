import SwiftUI

struct ProgressView: View {

    @StateObject private var vm = ProgressViewModel()

    let days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Text("Progress")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: - Streak
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Days Streak")
                            .font(.headline)
                        Spacer()
                        Text("\(vm.currentStreak)")
                            .font(.title.bold())
                    }

                    HStack {
                        ForEach(1...7, id: \.self) { i in
                            VStack {
                                Circle()
                                    .fill(vm.weekly[i] == true ? .orange : .gray.opacity(0.2))
                                    .frame(width: 24, height: 24)
                                Text(days[i-1])
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .padding()                            // ← Add padding
                .background(Color(.systemGray6))     // ← Add background
                .cornerRadius(16)                    // ← Add corner radius
                // ← Removed .card()

                StatRow(title: "Practicing English",
                        value: "\(vm.practiceMinutes)m",
                        icon: "clock.fill",
                        progress: min(Double(vm.practiceMinutes) / 60, 1))

                StatRow(title: "Words Spoken",
                        value: "\(vm.wordsSpoken)",
                        icon: "text.bubble.fill",
                        progress: min(Double(vm.wordsSpoken) / 1000, 1))

                StatRow(title: "Sentences Spoken",
                        value: "\(vm.sentencesSpoken)",
                        icon: "quote.bubble.fill",
                        progress: min(Double(vm.sentencesSpoken) / 500, 1))

                StatRow(title: "XP Conquered",
                        value: "\(vm.xp)",
                        icon: "star.fill",
                        progress: min(Double(vm.xp) / 5000, 1))

                StatRow(title: "Days Practicing",
                        value: "\(vm.daysPracticing)",
                        icon: "calendar",
                        progress: min(Double(vm.daysPracticing) / 30, 1))

                StatRow(title: "Longest Streak",
                        value: "\(vm.longestStreak)",
                        icon: "flame",
                        progress: min(Double(vm.longestStreak) / 30, 1))

                AchievementGrid(vm: vm)
            }
            .padding()
        }
        .onAppear { vm.load() }
    }
}
