import Foundation
import Combine
import SwiftUI

@MainActor
final class WordViewModel: ObservableObject {

    // MARK: - Published State
    @Published var currentWord: Word
    @Published var currentTask = 0
    @Published var streak = UserDefaults.standard.integer(forKey: "elo_streak")
    @Published var wordCompleted = false

    // MARK: - Difficulty (from Settings)
    @AppStorage("selectedDifficulty") private var selectedDifficulty: String = "Medium" {
        didSet {
            // Automatically refresh words when difficulty changes
            refreshWordsForCurrentDifficulty()
        }
    }

    // MARK: - Word Storage
    private var allWords: [Word] = []
    private var filteredWords: [Word] = []

    // MARK: - Init
    init() {
        // Temporary fallback
        self.currentWord = Word.hard.first!
        self.filteredWords = []
        self.allWords = []

        // Load words for the current difficulty
        refreshWordsForCurrentDifficulty()
    }

    // MARK: - Load Words
    private func loadWordsForDifficulty() {
        let words: [Word]
        switch selectedDifficulty {
        case "Easy":
            words = Word.easy
        case "Medium":
            words = Word.medium
        default:
            words = Word.hard
        }

        allWords = words.isEmpty ? Word.hard : words
        applyDifficultyFilter()
    }

    // MARK: - Difficulty Logic
    private func applyDifficultyFilter() {
        filteredWords = allWords.shuffled()
    }

    // MARK: - Daily Word Logic
    private func loadTodayWord() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: "elo_lastDate") as? Date ?? .distantPast

        if calendar.isDate(lastDate, inSameDayAs: today),
           let index = UserDefaults.standard.object(forKey: "elo_todayIndex") as? Int {

            currentWord = filteredWords[index % filteredWords.count]
            wordCompleted = UserDefaults.standard.bool(forKey: "elo_completedToday")

        } else {
            let newIndex = UserDefaults.standard.integer(forKey: "elo_todayIndex") + 1
            UserDefaults.standard.set(newIndex, forKey: "elo_todayIndex")
            UserDefaults.standard.set(today, forKey: "elo_lastDate")
            UserDefaults.standard.set(false, forKey: "elo_completedToday")

            currentWord = filteredWords[newIndex % filteredWords.count]
            currentTask = 0
            wordCompleted = false
        }
    }

    // MARK: - Public Refresh Method
    func refreshWordsForCurrentDifficulty() {
        loadWordsForDifficulty()
        loadTodayWord()
        currentTask = 0
        wordCompleted = UserDefaults.standard.bool(forKey: "elo_completedToday")
    }

    // MARK: - Progression
    func completeTask() {
        if currentTask < 2 {
            currentTask += 1
        } else {
            wordCompleted = true
            streak += 1
            UserDefaults.standard.set(streak, forKey: "elo_streak")
            UserDefaults.standard.set(true, forKey: "elo_completedToday")
        }
    }

    func nextWord() {
        let currentIndex = filteredWords.firstIndex(of: currentWord) ?? 0
        let nextIndex = (currentIndex + 1) % filteredWords.count
        currentWord = filteredWords[nextIndex]
        currentTask = 0
        wordCompleted = false
        UserDefaults.standard.set(false, forKey: "elo_completedToday")
    }

    // MARK: - Testing
    func resetForTesting() {
        currentTask = 0
        wordCompleted = false
        UserDefaults.standard.set(false, forKey: "elo_completedToday")
    }
}
