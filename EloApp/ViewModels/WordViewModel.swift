// ViewModels/WordViewModel.swift
import Foundation
import Combine

@MainActor
final class WordViewModel: ObservableObject {
    @Published var currentWord = Word.sampleWords[0]
    @Published var currentTask = 0        // 0=word, 1=sentence, 2=memory
    @Published var streak = UserDefaults.standard.integer(forKey: "elo_streak")
    @Published var wordCompleted = false
    
    private var allWords = Word.sampleWords.shuffled()
    
    init() { loadTodayWord() }
    
    private func loadTodayWord() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: "elo_lastDate") as? Date ?? .distantPast
        
        if calendar.isDate(lastDate, inSameDayAs: today),
           let index = UserDefaults.standard.object(forKey: "elo_todayIndex") as? Int {
            currentWord = allWords[index % allWords.count]
            wordCompleted = UserDefaults.standard.bool(forKey: "elo_completedToday")
        } else {
            let newIndex = UserDefaults.standard.integer(forKey: "elo_todayIndex") + 1
            UserDefaults.standard.set(newIndex, forKey: "elo_todayIndex")
            UserDefaults.standard.set(today, forKey: "elo_lastDate")
            UserDefaults.standard.set(false, forKey: "elo_completedToday")
            currentWord = allWords[newIndex % allWords.count]
            currentTask = 0
            wordCompleted = false
        }
    }
    
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
        let currentIndex = allWords.firstIndex(of: currentWord) ?? 0
        let nextIndex = (currentIndex + 1) % allWords.count
        currentWord = allWords[nextIndex]
        currentTask = 0
        wordCompleted = false
        UserDefaults.standard.set(false, forKey: "elo_completedToday")
    }
    
    func resetForTesting() {
        currentTask = 0
        wordCompleted = false
        UserDefaults.standard.set(false, forKey: "elo_completedToday")
    }
}
