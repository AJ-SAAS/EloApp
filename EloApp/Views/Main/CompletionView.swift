import SwiftUI
import StoreKit

struct CompletionView: View {
    let wordID: String
    let onContinue: () -> Void
    let xpGained: Int = 100  // Final completion bonus

    @EnvironmentObject var vm: ProgressViewModel
    @Environment(\.requestReview) private var requestReview  // <-- Add this

    // Animated properties
    @State private var animatedXP: Int = 0
    @State private var animatedStreak: Int = 0
    @State private var showConfetti = false
    @State private var scaleUp = false

    // Text messages
    @State private var motivationalText: String = ""
    @State private var tomorrowHookText: String = ""

    // App review tracking
    @AppStorage("completionCount") private var completionCount: Int = 0
    @AppStorage("lastVersionPromptedForReview") private var lastVersionPromptedForReview: String = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Top streak/XP display
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("🔥 Streak: \(animatedStreak)")
                            .font(.headline.bold())
                            .foregroundColor(.orange)
                        Text("XP: \(animatedXP)")
                            .font(.headline.bold())
                            .foregroundColor(.green)
                    }
                    Spacer()
                }
                .padding(.top, 50)
                Spacer()
            }

            // Main content
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(scaleUp ? 1.0 : 0.6)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: scaleUp)

                Text("WORD MASTERED")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    Text("🔥 \(animatedStreak)-day streak")
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                    Text("+\(xpGained) XP")
                        .font(.title3.bold())
                        .foregroundColor(.green)
                }

                Text(motivationalText)
                    .font(.headline.bold())
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text(tomorrowHookText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text("Daily goal completed")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Button(action: {
                    triggerSuccessHaptic()
                    onContinue()
                }) {
                    Text("Keep the streak alive →")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 18)
                        .background(Color.green)
                        .cornerRadius(24)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 30)

            if showConfetti {
                ConfettiView()
                    .zIndex(2)
            }
        }
        .onAppear {
            // Random messages
            motivationalText = [
                "You’re becoming a Precision Speaker!",
                "Your vocabulary is on fire! 🔥",
                "Every word counts! 💪",
                "Sharp communicator unlocked! 😎",
                "Keep leveling up your words! 🚀"
            ].randomElement()!

            tomorrowHookText = [
                "Tomorrow’s word helps you sound more confident in conversations.",
                "Tomorrow you’ll learn a word native speakers actually use.",
                "Tomorrow’s word will make you a sharper communicator."
            ].randomElement()!

            // Animations
            scaleUp = true
            triggerSuccessHaptic()

            // Start animations from current values (XP already added in DailyWordView)
            animatedXP = vm.xp
            animatedStreak = vm.currentStreak

            // Optional confetti on level up
            if vm.didLevelUp {
                withAnimation { showConfetti = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { showConfetti = false }
                }
            }

            // --- APP REVIEW LOGIC ---
            completionCount += 1
            if shouldPromptForReview() {
                presentReview()
            }
        }
    }

    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // MARK: - App Review Logic

    private func shouldPromptForReview() -> Bool {
        // Only prompt if user has completed enough sessions AND hasn't been prompted for this app version
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        return completionCount >= 4 && lastVersionPromptedForReview != currentVersion
    }

    private func presentReview() {
        Task {
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2-second delay
            await requestReview()
            lastVersionPromptedForReview = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }
    }
}
