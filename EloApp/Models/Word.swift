// Models/Word.swift
import Foundation

enum WordDifficulty: String, Codable {
    case easy
    case medium
    case hard
}

struct Word: Identifiable, Codable, Equatable {
    var id = UUID()
    let word: String
    let pronunciation: String
    let definition: String
    let sentence: String
    let difficulty: WordDifficulty
}
