import Foundation
import SwiftUI
import Combine

@MainActor
final class ProgressViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var practiceSeconds = 0
    @Published var wordsSpoken = 0
    @Published var sentencesSpoken = 0
    @Published var xp = 0
    @Published var daysPracticing = 0
    @Published var longestStreak = 0
    @Published var currentStreak = 0
    @Published var weekly: [Int: Bool] = [:]

    @Published var didLevelUp: Bool = false
    @Published var weeklyGrowthPercent: Int = 0
    @Published var level: Int = 1

    private let tracker = ProgressTracker.shared

    // MARK: - XP per word tracking
    private var rewardedWords: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: "elo_xpGivenWords") ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: "elo_xpGivenWords") }
    }

    // MARK: - Initialization
    init() {
        load()
    }

    // MARK: - Load Progress
    func load() {
        practiceSeconds = tracker.totalPracticeSeconds
        wordsSpoken = tracker.wordsSpoken
        sentencesSpoken = tracker.sentencesSpoken
        xp = tracker.xp
        daysPracticing = tracker.daysPracticing
        longestStreak = tracker.longestStreak
        currentStreak = tracker.currentStreak
        weekly = tracker.weeklyCompletion

        // Weekly growth placeholder
        weeklyGrowthPercent = Int.random(in: 0...50)

        // Level calculation based on XP
        level = xp / 1000 + 1

        // Level up check
        didLevelUp = false
        if xp >= level * 1000 {
            didLevelUp = true
        }

        // Reset week if needed
        tracker.resetWeekIfNeeded()
    }

    // MARK: - Word-based XP addition
    func addXP(forWordID wordID: String, amount: Int) {
        // Check if XP already rewarded for this word
        guard !rewardedWords.contains(wordID) else { return }

        // Add word to rewarded set
        var newSet = rewardedWords
        newSet.insert(wordID)
        rewardedWords = newSet

        // Update XP
        let newXP = xp + amount
        xp = newXP
        UserDefaults.standard.set(newXP, forKey: "elo_totalXP")

        // Check level up
        let newLevel = newXP / 1000 + 1
        if newLevel > level {
            level = newLevel
            didLevelUp = true
        }
    }

    // MARK: - Refresh
    func refresh() {
        load()
    }

    // MARK: - Computed Properties
    var practiceMinutes: Int {
        practiceSeconds / 60
    }
}
