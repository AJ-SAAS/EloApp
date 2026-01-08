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

    // MARK: - Daily Word / Premium Properties
    @Published var dailyWordsUsed: Int = 0
    @Published var canPracticeDailyWord: Bool = true
    @Published var hasPremiumAccess: Bool = false

    private let tracker = ProgressTracker.shared

    // MARK: - Task-Based XP Tracking
    /// key = wordID, value = set of completed tasks (0 = word, 1 = sentence, 2 = memory, 3 = completion bonus)
    private var rewardedWordTasks: [String: Set<Int>] {
        get {
            (UserDefaults.standard.dictionary(forKey: "elo_rewardedWordTasks") as? [String: [Int]])?.mapValues { Set($0) } ?? [:]
        }
        set {
            let dict = newValue.mapValues { Array($0) }
            UserDefaults.standard.set(dict, forKey: "elo_rewardedWordTasks")
        }
    }

    // MARK: - Initialization
    init() {
        load()
        hasPremiumAccess = tracker.hasPremiumAccess
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

        weeklyGrowthPercent = Int.random(in: 0...50)

        level = xp / 1000 + 1
        didLevelUp = false
        if xp >= level * 1000 {
            didLevelUp = true
        }

        dailyWordsUsed = tracker.dailyWordsUsed
        canPracticeDailyWord = tracker.canPracticeWord(isPremium: hasPremiumAccess)
    }

    // MARK: - Add XP for a specific task
    /// task: 0 = say word, 1 = say sentence, 2 = memory, 3 = completion bonus
    func addXP(forWordID wordID: String, task: Int, amount: Int) {
        var tasks = rewardedWordTasks[wordID] ?? []

        // Only add XP if this task hasn't been rewarded yet
        guard !tasks.contains(task) else { return }

        // Update task tracking
        tasks.insert(task)
        var updatedDict = rewardedWordTasks
        updatedDict[wordID] = tasks
        rewardedWordTasks = updatedDict

        // Add XP
        xp += amount
        UserDefaults.standard.set(xp, forKey: "elo_totalXP")

        // Check level up
        let newLevel = xp / 1000 + 1
        if newLevel > level {
            level = newLevel
            didLevelUp = true
        }
    }

    // MARK: - Check if task is completed for a word
    func isTaskCompleted(wordID: String, task: Int) -> Bool {
        rewardedWordTasks[wordID]?.contains(task) ?? false
    }

    // MARK: - Increment Daily Word Usage
    func incrementDailyWordCount() {
        tracker.incrementDailyWordCount()
        dailyWordsUsed = tracker.dailyWordsUsed
        canPracticeDailyWord = tracker.canPracticeWord(isPremium: hasPremiumAccess)
    }

    // MARK: - Refresh
    func refresh() {
        load()
    }

    // MARK: - Computed Properties
    var practiceMinutes: Int {
        practiceSeconds / 60
    }

    // MARK: - Update Premium Status
    func updatePremiumStatus(isPremium: Bool) {
        hasPremiumAccess = isPremium
        tracker.hasPremiumAccess = isPremium
        canPracticeDailyWord = tracker.canPracticeWord(isPremium: isPremium)
    }

    // MARK: - Reset XP Tracking (optional, for testing)
    func resetXPTracking() {
        UserDefaults.standard.removeObject(forKey: "elo_rewardedWordTasks")
    }
}
