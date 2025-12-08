import Foundation
import AVFoundation

@MainActor
class DailyPracticeViewModel: ObservableObject {

    @Published var attempt: Int = 1      // 1 → 2 → 3
    @Published var isRecording = false
    @Published var streak: Int = 0

    @Published var today: DailyPractice = DailyPractice(
        word: "Articulate",
        sentence: "I want to articulate my ideas clearly."
    )

    private let recorder = AudioRecorderService()

    // MARK: - Attempt Logic
    func startRecording() {
        isRecording = true
        recorder.startRecording()
    }

    func stopRecording() {
        isRecording = false

        let savedURL = recorder.stopRecording()
        print("🎤 Saved attempt recording:", savedURL?.lastPathComponent ?? "nil")

        advanceAttempt()
    }

    private func advanceAttempt() {
        if attempt < 3 {
            attempt += 1
        } else {
            completeDailyPractice()
        }
    }

    private func completeDailyPractice() {
        streak += 1
        attempt = 1   // reset for next day
    }

    // MARK: - Helpers
    var hideSentence: Bool {
        attempt == 3
    }
}
