import SwiftUI

struct ProgressScreen: View {

    @EnvironmentObject private var vm: ProgressViewModel
    @StateObject private var purchaseVM = PurchaseViewModel()

    @State private var animateProgress: Bool = false
    @State private var showLevelUp: Bool = false
    @State private var showPaywall: Bool = false

    let days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    private let duolingoGreenCard = Color(red: 217/255, green: 241/255, blue: 198/255)
    private let duolingoGreenPrimary = Color(red: 88/255, green: 204/255, blue: 2/255)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Header
                Text("Progress")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Streak Card
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "flame.fill").foregroundColor(.orange)
                        Text("Days Streak").font(.headline)
                        Spacer()
                        Text("\(vm.currentStreak)").font(.title.bold())
                    }
                    HStack(spacing: 8) {
                        ForEach(1...7, id: \.self) { i in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(vm.weekly[i] == true
                                          ? duolingoGreenPrimary
                                          : Color.white.opacity(0.6))
                                    .frame(width: 24, height: 24)
                                Text(days[i-1])
                                    .font(.caption2)
                                    .foregroundColor(.black.opacity(0.6))
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(duolingoGreenCard))

                // Basic Stats (Free + Premium)
                statsRow(title: "Practice Time", value: "\(vm.practiceMinutes)m", icon: "clock.fill", progress: min(Double(vm.practiceMinutes)/60, 1))
                statsRow(title: "Words Spoken", value: "\(vm.wordsSpoken)", icon: "text.bubble.fill", progress: min(Double(vm.wordsSpoken)/1000, 1))
                statsRow(title: "Sentences Spoken", value: "\(vm.sentencesSpoken)", icon: "quote.bubble.fill", progress: min(Double(vm.sentencesSpoken)/500, 1))

                // Advanced Stats (Soft-Locked)
                if vm.hasPremiumAccess || purchaseVM.hasPremiumAccess() {
                    statsRow(title: "XP Conquered", value: "\(vm.xp)", icon: "star.fill", progress: min(Double(vm.xp)/5000, 1), color: .yellow)
                    statsRow(title: "Days Practicing", value: "\(vm.daysPracticing)", icon: "calendar", progress: min(Double(vm.daysPracticing)/30, 1), color: .teal)
                    statsRow(title: "Longest Streak", value: "\(vm.longestStreak)", icon: "flame", progress: min(Double(vm.longestStreak)/30, 1), color: .orange)
                    if vm.weeklyGrowthPercent > 0 {
                        Text("+\(vm.weeklyGrowthPercent)% vs last week")
                            .font(.caption)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 8)
                    }
                } else {
                    LockedStatsView(title: "Advanced Progress 🔒",
                                    subtitle: "Unlock premium for full insights") {
                        showPaywall = true
                    }
                }

                AchievementGrid(vm: vm)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { animateProgress = true }
            vm.load()
        }
        .onChange(of: vm.didLevelUp) { leveledUp in
            guard leveledUp else { return }
            Haptics.success()
            showLevelUp = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { showLevelUp = false }
                vm.didLevelUp = false
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(vm: OnboardingViewModel())
        }
        .overlay(
            Group {
                if showLevelUp {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("🎉 Level Up! Now Lv. \(vm.level)")
                                .font(.title2.bold())
                                .padding()
                                .background(
                                    LinearGradient(colors: [.yellow, .orange],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                            Spacer()
                        }
                        .padding(.bottom, 40)
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }

    // MARK: - Reusable Stat Row
    private func statsRow(title: String, value: String, icon: String, progress: Double, color: Color = .blue) -> some View {
        StatRow(title: title, value: value, icon: icon, progress: progress, color: color, animate: $animateProgress)
    }
}

// MARK: - Locked Stats for Free Users
struct LockedStatsView: View {
    let title: String
    let subtitle: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "lock.fill").foregroundColor(.gray)
                    Text(title).font(.headline)
                    Spacer()
                }
                Text(subtitle).font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
