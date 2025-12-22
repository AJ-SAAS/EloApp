import SwiftUI

struct AchievementGrid: View {
    
    @ObservedObject var vm: ProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                badge("🔥 7-Day Streak", unlocked: vm.longestStreak >= 7)
                badge("💬 100 Words", unlocked: vm.wordsSpoken >= 100)
                badge("⭐ 1,000 XP", unlocked: vm.xp >= 1000)
                badge("📆 30 Days", unlocked: vm.daysPracticing >= 30)
                
                // Extra achievements to make it more engaging
                badge("🗣️ 500 Sentences", unlocked: vm.sentencesSpoken >= 500)
                badge("⏰ 1 Hour Practiced", unlocked: vm.practiceMinutes >= 60)
                badge("🌟 5,000 XP", unlocked: vm.xp >= 5000)
                badge("🔥 30-Day Streak", unlocked: vm.longestStreak >= 30)
                badge("💯 1,000 Words", unlocked: vm.wordsSpoken >= 1000)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func badge(_ title: String, unlocked: Bool) -> some View {
        VStack(spacing: 8) {
            Text(unlocked ? "✅" : "🔒")
                .font(.largeTitle)
            
            Text(title)
                .font(.caption.bold())
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .padding()
        .background(unlocked ? Color.green.opacity(0.25) : Color.gray.opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(unlocked ? Color.green.opacity(0.6) : Color.clear, lineWidth: 2)
        )
    }
}
