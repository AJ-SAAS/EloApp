// Models/Word.swift
import Foundation

struct Word: Identifiable, Codable, Equatable {
    var id = UUID()                    // ← make it var, not let
    let word: String
    let pronunciation: String
    let definition: String
    let sentence: String
    
    static let sampleWords: [Word] = [
        Word(word: "Ephemeral", pronunciation: "ih-FEM-er-uhl",
             definition: "Lasting for a very short time",
             sentence: "The beauty of cherry blossoms is ephemeral."),
        Word(word: "Serendipity", pronunciation: "ser-en-DIP-i-tee",
             definition: "Finding something good without looking for it",
             sentence: "Meeting you here was pure serendipity."),
        Word(word: "Quintessential", pronunciation: "kwin-tuh-SEN-shuhl",
             definition: "Representing the most perfect example",
             sentence: "She is the quintessential New Yorker."),
        Word(word: "Eloquent", pronunciation: "EL-uh-kwuhnt",
             definition: "Fluent and persuasive in speaking",
             sentence: "His eloquent speech moved the audience."),
        Word(word: "Ubiquitous", pronunciation: "yoo-BIK-wi-tuhs",
             definition: "Present everywhere",
             sentence: "Smartphones are now ubiquitous."),
        // Add more whenever you want
    ]
}
