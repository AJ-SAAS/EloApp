import SwiftUI

struct AchievementGrid: View {

    @ObservedObject var vm: ProgressViewModel
    @State private var animateUnlocks: Bool = false

    let badgeColors: [String: Color] = [
        "🔥": .orange,
        "💬": .purple,
        "⭐": .yellow,
        "📆": .teal,
        "🗣️": .pink,
        "⏰": .blue,
        "🌟": .yellow,
        "💯": .green
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
                .padding(.bottom, 4)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                achievementBadge(title: "🔥 7-Day Streak", unlocked: vm.longestStreak >= 7)
                achievementBadge(title: "💬 100 Words", unlocked: vm.wordsSpoken >= 100)
                achievementBadge(title: "⭐ 1,000 XP", unlocked: vm.xp >= 1000)
                achievementBadge(title: "📆 30 Days", unlocked: vm.daysPracticing >= 30)
                achievementBadge(title: "🗣️ 500 Sentences", unlocked: vm.sentencesSpoken >= 500)
                achievementBadge(title: "⏰ 1 Hour Practiced", unlocked: vm.practiceMinutes >= 60)
                achievementBadge(title: "🌟 5,000 XP", unlocked: vm.xp >= 5000)
                achievementBadge(title: "🔥 30-Day Streak", unlocked: vm.longestStreak >= 30)
                achievementBadge(title: "💯 1,000 Words", unlocked: vm.wordsSpoken >= 1000)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .onAppear {
            withAnimation(.easeOut.delay(0.2)) {
                animateUnlocks = true
            }
        }
    }

    @ViewBuilder
    private func achievementBadge(title: String, unlocked: Bool) -> some View {
        let icon = String(title.prefix(1))
        let color = badgeColors[icon] ?? .blue

        VStack(spacing: 8) {
            Text(unlocked ? "✅" : "🔒")
                .font(.largeTitle)
                .scaleEffect(animateUnlocks && unlocked ? 1.2 : 1)
                .animation(
                    .interpolatingSpring(stiffness: 200, damping: 10)
                    .delay(unlocked ? Double.random(in: 0.1...0.5) : 0),
                    value: animateUnlocks
                )
                .shadow(color: unlocked && animateUnlocks ? color.opacity(0.6) : .clear, radius: 6, x: 0, y: 0)

            Text(title)
                .font(.caption.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(unlocked ? .primary : .gray)
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .padding()
        .background(
            unlocked ? color.opacity(0.25) : Color.gray.opacity(0.15)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(unlocked ? color.opacity(0.6) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(animateUnlocks ? 1 : 0.8)
        .opacity(animateUnlocks ? 1 : 0)
        .animation(.easeOut.delay(Double.random(in: 0.05...0.3)), value: animateUnlocks)
    }
}
