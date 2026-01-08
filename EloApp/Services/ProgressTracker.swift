import Foundation
import Combine

@MainActor
final class ProgressTracker: ObservableObject {

    static let shared = ProgressTracker()
    private let defaults = UserDefaults.standard

    // MARK: - Free Limits
    static let freeWordsPerDay = 3

    // MARK: - Reactive onboarding flag
    @Published private(set) var onboardingCompleted: Bool

    // MARK: - Premium Access
    @Published var hasPremiumAccess: Bool = false // Track premium access

    private init() {
        self.onboardingCompleted = defaults.bool(forKey: Key.onboardingCompleted)
        resetDailyWordsIfNeeded()
    }

    // MARK: - Keys
    private enum Key {
        static let practiceSeconds = "elo_totalPracticeSeconds"
        static let wordsSpoken = "elo_wordsSpoken"
        static let sentencesSpoken = "elo_sentencesSpoken"
        static let xp = "elo_totalXP"
        static let daysPracticing = "elo_daysPracticing"
        static let streak = "elo_streak"
        static let longestStreak = "elo_longestStreak"
        static let lastPracticeDate = "elo_lastPracticeDate"
        static let onboardingCompleted = "elo_onboardingCompleted"

        static let dailyWordsCount = "elo_dailyWordsCount"
        static let dailyWordsDate = "elo_dailyWordsDate"
    }

    // MARK: - Daily Word Limit
    var dailyWordsUsed: Int {
        resetDailyWordsIfNeeded()
        return defaults.integer(forKey: Key.dailyWordsCount)
    }

    /// Check if user can practice the daily word
    func canPracticeWord(isPremium: Bool) -> Bool {
        isPremium || dailyWordsUsed < Self.freeWordsPerDay
    }

    /// Increment daily word usage counter
    func incrementDailyWordCount() {
        resetDailyWordsIfNeeded()
        defaults.set(dailyWordsUsed + 1, forKey: Key.dailyWordsCount)
    }

    /// Reset daily word counter if it's a new day
    private func resetDailyWordsIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = defaults.object(forKey: Key.dailyWordsDate) as? Date

        if lastDate == nil || !Calendar.current.isDate(today, inSameDayAs: lastDate!) {
            defaults.set(0, forKey: Key.dailyWordsCount)
            defaults.set(today, forKey: Key.dailyWordsDate)
        }
    }

    // MARK: - Computed Properties
    var totalPracticeSeconds: Int { defaults.integer(forKey: Key.practiceSeconds) }
    var wordsSpoken: Int { defaults.integer(forKey: Key.wordsSpoken) }
    var sentencesSpoken: Int { defaults.integer(forKey: Key.sentencesSpoken) }
    var xp: Int { defaults.integer(forKey: Key.xp) }
    var daysPracticing: Int { defaults.integer(forKey: Key.daysPracticing) }
    var currentStreak: Int { defaults.integer(forKey: Key.streak) }
    var longestStreak: Int { defaults.integer(forKey: Key.longestStreak) }

    var weeklyCompletion: [Int: Bool] {
        var dict: [Int: Bool] = [:]
        for day in 1...7 {
            dict[day] = defaults.bool(forKey: "elo_weekday_\(day)")
        }
        return dict
    }

    // MARK: - Onboarding
    var isOnboardingCompleted: Bool {
        onboardingCompleted
    }

    func markOnboardingCompleted() {
        onboardingCompleted = true
        defaults.set(true, forKey: Key.onboardingCompleted)
    }

    func resetOnboarding() {
        onboardingCompleted = false
        defaults.set(false, forKey: Key.onboardingCompleted)
    }

    // MARK: - Tracking
    func trackPractice(seconds: Int) {
        addInt(seconds, for: Key.practiceSeconds)
        updateDayTracking()
    }

    func trackWordSpoken() {
        addInt(1, for: Key.wordsSpoken)
        updateDayTracking()
    }

    func trackSentenceSpoken() {
        addInt(1, for: Key.sentencesSpoken)
        updateDayTracking()
    }

    func trackXP(_ amount: Int) {
        addInt(amount, for: Key.xp)
    }

    // MARK: - Day & Streak Logic
    private func updateDayTracking() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = defaults.object(forKey: Key.lastPracticeDate) as? Date

        if lastDate == nil || !Calendar.current.isDate(today, inSameDayAs: lastDate!) {
            addInt(1, for: Key.daysPracticing)
            updateStreak(on: today, lastDate: lastDate)
            defaults.set(today, forKey: Key.lastPracticeDate)
        }

        updateWeeklyCompletion()
    }

    private func updateStreak(on today: Date, lastDate: Date?) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let current = defaults.integer(forKey: Key.streak)

        if let last = lastDate, Calendar.current.isDate(last, inSameDayAs: yesterday) {
            let newStreak = current + 1
            defaults.set(newStreak, forKey: Key.streak)
            defaults.set(max(newStreak, longestStreak), forKey: Key.longestStreak)
        } else {
            defaults.set(1, forKey: Key.streak)
        }
    }

    private func updateWeeklyCompletion() {
        let weekday = Calendar.current.component(.weekday, from: Date())
        defaults.set(true, forKey: "elo_weekday_\(weekday)")
    }

    private func addInt(_ value: Int, for key: String) {
        defaults.set(defaults.integer(forKey: key) + value, forKey: key)
    }
}
