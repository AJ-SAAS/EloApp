import Foundation
import SwiftUI
import Combine   // ← ADD THIS

@MainActor
final class ProgressViewModel: ObservableObject {

    @Published var practiceSeconds = 0
    @Published var wordsSpoken = 0
    @Published var sentencesSpoken = 0
    @Published var xp = 0
    @Published var daysPracticing = 0
    @Published var longestStreak = 0
    @Published var currentStreak = 0

    @Published var weekly: [Int: Bool] = [:]

    private let tracker = ProgressTracker.shared

    init() {
        load()
    }

    /// Load all progress data from the single source of truth: ProgressTracker
    func load() {
        practiceSeconds = tracker.totalPracticeSeconds
        wordsSpoken = tracker.wordsSpoken
        sentencesSpoken = tracker.sentencesSpoken
        xp = tracker.xp
        daysPracticing = tracker.daysPracticing
        longestStreak = tracker.longestStreak
        currentStreak = tracker.currentStreak
        weekly = tracker.weeklyCompletion

        // Still keep this in case the app is opened on a Sunday
        tracker.resetWeekIfNeeded()
    }

    /// Optional: Call this if you want to refresh stats while the Progress tab is visible
    /// (e.g., after returning from background or if you add live updates later)
    func refresh() {
        load()
    }

    var practiceMinutes: Int {
        practiceSeconds / 60
    }
}
