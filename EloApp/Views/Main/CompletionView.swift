import SwiftUI

struct CompletionView: View {
    let onContinue: () -> Void

    @State private var showConfetti = false
    @State private var scaleUp = false
    @State private var dayStreak: Int = 0
    @State private var xpGained: Int = 100
    @State private var animatedXP: Int = 0
    @State private var animatedStreak: Int = 0

    // State variables for random texts
    @State private var motivationalText: String = ""
    @State private var tomorrowHookText: String = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Top streak / XP bar
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

            VStack(spacing: 20) {
                // Trophy
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(scaleUp ? 1.0 : 0.6)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: scaleUp)

                // Word Mastered
                Text("WORD MASTERED")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                // Day streak & XP (central animated)
                VStack(spacing: 8) {
                    Text("🔥 \(animatedStreak)-day streak")
                        .font(.title2.bold())
                        .foregroundColor(.orange)

                    Text("+\(animatedXP) XP")
                        .font(.title3.bold())
                        .foregroundColor(.green)
                }

                // Motivational text
                Text(motivationalText)
                    .font(.headline.bold())
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                // Tomorrow hook
                Text(tomorrowHookText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text("Daily goal completed")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Keep streak alive button
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

            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .zIndex(2)
            }
        }
        .onAppear {
            // Pick random texts once
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

            // Start animations and haptics
            scaleUp = true
            triggerSuccessHaptic()
            updateDayStreak()
            animateStreakAndXP {
                // Keep confetti for 2 seconds after XP is added
                withAnimation {
                    showConfetti = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        showConfetti = false
                    }
                }
            }
        }
    }

    // MARK: - Day streak logic
    private func updateDayStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: "elo_lastStreakDate") as? Date ?? Date.distantPast

        if !Calendar.current.isDate(today, inSameDayAs: lastDate) {
            let newStreak = UserDefaults.standard.integer(forKey: "elo_dayStreak") + 1
            UserDefaults.standard.set(today, forKey: "elo_lastStreakDate")
            UserDefaults.standard.set(newStreak, forKey: "elo_dayStreak")
        }

        dayStreak = UserDefaults.standard.integer(forKey: "elo_dayStreak")
    }

    // MARK: - Animate streak and XP sequentially
    private func animateStreakAndXP(completion: @escaping () -> Void) {
        let previousStreak = max(UserDefaults.standard.integer(forKey: "elo_dayStreak") - 1, 0)
        animateValue(from: previousStreak, to: dayStreak, duration: 1.0) { value in
            animatedStreak = value
        }

        let previousXP = UserDefaults.standard.integer(forKey: "elo_totalXP")
        let newTotalXP = previousXP + xpGained
        UserDefaults.standard.set(newTotalXP, forKey: "elo_totalXP")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateValue(from: previousXP, to: newTotalXP, duration: 0.8) { value in
                animatedXP = value
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                completion()
            }
        }
    }

    // MARK: - Animate integer values
    private func animateValue(from start: Int, to end: Int, duration: Double, update: @escaping (Int) -> Void) {
        let steps = 30
        let interval = duration / Double(steps)
        let increment = max(1, (end - start) / steps)
        var current = start
        var stepCount = 0

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if stepCount >= steps {
                update(end)
                timer.invalidate()
            } else {
                current += increment
                update(min(current, end))
                stepCount += 1
            }
        }
    }

    // MARK: - Haptic
    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
