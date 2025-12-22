import SwiftUI
import AVFoundation

enum VoiceOption: String, CaseIterable {
    case usMale = "US Male"
    case usFemale = "US Female"
    case gbMale = "GB Male"
    case gbFemale = "GB Female"
    
    var voiceIdentifier: String {
        switch self {
        case .usMale: return "com.apple.ttsbundle.Fred-compact"
        case .usFemale: return "com.apple.ttsbundle.Samantha-compact"
        case .gbMale: return "com.apple.ttsbundle.Daniel-compact"
        case .gbFemale: return "com.apple.ttsbundle.Karen-compact"
        }
    }
}

struct DailyWordView: View {
    @StateObject private var vm = WordViewModel()
    @StateObject private var speech = SpeechService()
    
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @AppStorage("selectedVoice") private var selectedVoice: String = VoiceOption.gbFemale.rawValue
    @AppStorage("selectedDifficulty") private var selectedDifficulty: String = "Hard"

    // UI State
    @State private var spokenText = ""
    @State private var showTryAgain = false
    @State private var amplitude: CGFloat = 0.0
    @State private var showConfetti = false
    @State private var toastText: String? = nil
    @State private var showToast = false
    @State private var xpGained: Int = 0
    @State private var animatedStreak: Int = 0
    @State private var animatedXP: Int = 0
    @State private var showFloatingXP = false
    @State private var floatingXPText = "+0 XP"
    @State private var floatingXPOffset: CGFloat = 0
    @State private var showCompletion = false
    @State private var showHint = false

    private var prompt: String {
        switch vm.currentTask {
        case 0: return "Tap mic & say the word aloud"
        case 1: return "Tap mic & say the full sentence"
        case 2: return "Say the sentence from memory"
        default: return ""
        }
    }

    private var targetText: String {
        vm.currentTask == 0
            ? vm.currentWord.word.lowercased()
            : vm.currentWord.sentence.lowercased()
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 16) {  // ← Reduced from 24 to 16
                
                Spacer().frame(height: 40)  // ← Slightly reduced top space
                
                // Top bar: Next button top-right
                HStack {
                    Spacer()
                    Button(action: {
                        vm.nextWord()
                        resetUI()
                    }) {
                        Text("Next")
                            .font(.headline.bold())
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
                
                // Streak / XP centered
                VStack(spacing: 4) {
                    Text("🔥 Streak: \(animatedStreak)")
                        .font(.headline.bold())
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    Text("XP: \(animatedXP)")
                        .font(.headline.bold())
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                
                // Word of the day
                Text(vm.currentWord.word)
                    .font(.system(size: 72, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Definition
                Text("Definition: \(vm.currentWord.definition)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Pronunciation button
                pronunciationButton
                    .padding(.vertical, 6)
                
                // Sentence box / Hint for memory task — no inner ScrollView
                VStack {
                    if vm.currentTask == 2 && !showHint {
                        Button(action: { showHint.toggle() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb")
                                Text("Show Hint")
                            }
                            .font(.subheadline.bold())
                            .padding()
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(12)
                        }
                    } else {
                        Text("“\(vm.currentWord.sentence)”")
                            .font(.title2)
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal)
                .frame(minHeight: 80)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Task boxes
                HStack(spacing: 12) {
                    TaskBox(title: "Word", isCompleted: vm.currentTask >= 0)
                    TaskBox(title: "Sentence", isCompleted: vm.currentTask >= 1)
                    TaskBox(title: "Memory", isCompleted: vm.currentTask >= 2)
                }
                
                // Prompt or live transcription — compact
                if speech.isRecording {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("You said:")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        Text(spokenText.isEmpty ? "Listening…" : spokenText)
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 8)
                } else {
                    Text(prompt)
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                }
                
                if showTryAgain {
                    Text("Try again — speak clearly")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                // Mic button — safe from tab bar
                micButton
                    .padding(.top, 20)
                    .padding(.bottom, 90)  // ← Extra safe space above tab bar
                
                Spacer()
            }
            
            // Overlays
            if showConfetti && vm.currentTask < 2 {
                ConfettiView()
            }
            
            if showToast, let toastText {
                VStack {
                    Text(toastText)
                        .font(.headline.bold())
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.black.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(18)
                        .padding(.top, 180)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeOut, value: showToast)
                }
            }
            
            if showCompletion {
                CompletionView {
                    showCompletion = false
                    vm.nextWord()
                    resetUI()
                    showHint = false
                }
            }
        }
        .onAppear {
            speech.requestPermission()
            animatedStreak = ProgressTracker.shared.currentStreak
            animatedXP = ProgressTracker.shared.xp
            vm.refreshWordsForCurrentDifficulty()
        }
        .onChange(of: selectedDifficulty) { _ in
            vm.refreshWordsForCurrentDifficulty()
            resetUI()
        }
    }

    // MARK: - Permission-aware mic button
    private var micButton: some View {
        Group {
            if speech.micAvailable {
                Circle()
                    .fill(speech.isRecording ? .red : .blue)
                    .frame(width: 150, height: 150)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    )
                    .onTapGesture { handleMicTap() }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("Microphone Disabled")
                        .font(.headline)

                    Text("Enable microphone access in Settings to practice speaking.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Button(action: openSystemSettings) {
                        Text("Enable Microphone in Settings")
                            .font(.headline.bold())
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
            }
        }
    }

    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private var pronunciationButton: some View {
        Button {
            speak(vm.currentWord.word + ". " + vm.currentWord.sentence)
        } label: {
            Label(vm.currentWord.pronunciation, systemImage: "speaker.wave.2.fill")
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)
        }
    }

    private func handleMicTap() {
        guard speech.micAvailable else { return }

        if speech.isRecording {
            speech.stopRecording()
            guard !spokenText.isEmpty else { return }
            
            if isMatch(spoken: spokenText) {
                celebrateTask()
            } else {
                showTryAgain = true
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        } else {
            spokenText = ""
            showTryAgain = false
            speech.startRecording { text in
                spokenText = text
            }
        }
    }

    private func celebrateTask() {
        let xpAmounts = [10, 15, 25]
        let xp = xpAmounts[vm.currentTask]
        xpGained = xp
        
        let messages = ["Nice 👍", "Great job 😎", "Perfect 🎉"]
        toastText = messages[vm.currentTask]
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        ProgressTracker.shared.trackXP(xp)
        
        if vm.currentTask == 0 {
            ProgressTracker.shared.trackWordSpoken()
        } else {
            ProgressTracker.shared.trackSentenceSpoken()
        }
        
        ProgressTracker.shared.trackPractice(seconds: 12)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showToast = true
                floatingXPText = "+\(xp) XP"
                floatingXPOffset = 0
                showFloatingXP = true
                withAnimation(.easeOut(duration: 1.0)) {
                    floatingXPOffset = -30
                }
            }

            let newXP = ProgressTracker.shared.xp
            animateValue(from: animatedXP, to: newXP, duration: 0.8) { animatedXP = $0 }
        }
        
        if vm.currentTask < 2 {
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation {
                    showToast = false
                    showFloatingXP = false
                    showConfetti = false
                }
                showHint = false
                spokenText = ""
                vm.completeTask()
            }
        } else {
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showConfetti = false
                    showCompletion = true
                    showToast = false
                    showFloatingXP = false
                    spokenText = ""
                    showHint = false
                }
            }
        }

        let newStreak = ProgressTracker.shared.currentStreak
        animateValue(from: animatedStreak, to: newStreak, duration: 1.0) { animatedStreak = $0 }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        let option = VoiceOption(rawValue: selectedVoice) ?? .gbFemale
        utterance.voice = AVSpeechSynthesisVoice(identifier: option.voiceIdentifier)
        utterance.rate = 0.48
        speechSynthesizer.speak(utterance)
    }

    private func isMatch(spoken: String) -> Bool {
        let cleanSpoken = spoken.lowercased().filter { $0.isLetter || $0 == " " }
        let cleanTarget = targetText.filter { $0.isLetter || $0 == " " }
        return cleanSpoken.contains(cleanTarget)
    }

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

    private func resetUI() {
        spokenText = ""
        showTryAgain = false
        showHint = false
    }
}

// MARK: - Task Box
struct TaskBox: View {
    let title: String
    let isCompleted: Bool
    
    var body: some View {
        Text(title)
            .font(.subheadline.bold())
            .foregroundColor(isCompleted ? .white : .gray)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isCompleted ? Color.green : Color.gray.opacity(0.2))
            .cornerRadius(12)
    }
}
