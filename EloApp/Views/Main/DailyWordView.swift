// Views/Main/DailyWordView.swift
// FINAL – PERFECT SPACING, NO CUT-OFF, BEAUTIFUL ON ALL DEVICES

import SwiftUI
import AVFoundation
import Speech

struct DailyWordView: View {
    @StateObject private var vm = WordViewModel()
    @StateObject private var speech = SpeechService()
    
    @State private var spokenText = ""
    @State private var showConfetti = false
    @State private var isPronouncing = false
    
    private var targetText: String {
        vm.currentTask == 0 ? vm.currentWord.word.lowercased() : vm.currentWord.sentence.lowercased()
    }
    
    private var prompt: String {
        switch vm.currentTask {
        case 0: "Hold mic and say the word"
        case 1: "Now say the full sentence"
        case 2: "Final round — from memory!"
        default: ""
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if vm.wordCompleted {
                CompletionView(streak: vm.streak) { vm.resetForTesting() }
            } else {
                VStack(spacing: 0) {
                    // TOP: Streak
                    Text("Streak: \(vm.streak) fire")
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // MAIN CONTENT CARD
                    VStack(spacing: 28) {
                        Text(vm.currentWord.word)
                            .font(.system(size: 58, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                        
                        // PRONUNCIATION BUTTON
                        Button {
                            withAnimation { isPronouncing = true }
                            speak(vm.currentWord.word + ". " + vm.currentWord.sentence)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation { isPronouncing = false }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                Text(vm.currentWord.pronunciation)
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 26)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.blue.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(isPronouncing ? 0.94 : 1.0)
                        .animation(.spring(response: 0.3), value: isPronouncing)
                        
                        // DEFINITION + SENTENCE (no more cut-off!)
                        if vm.currentTask < 2 {
                            VStack(spacing: 16) {
                                Text(vm.currentWord.definition)
                                    .font(.title3)
                                    .foregroundColor(.black.opacity(0.85))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("“\(vm.currentWord.sentence)”")
                                    .font(.title3)
                                    .italic()
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 30)
                            }
                            .padding(.horizontal, 30)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    // PROGRESS DOTS
                    HStack(spacing: 22) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(i <= vm.currentTask ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 34, height: 34)
                        }
                    }
                    
                    // PROMPT
                    Text(prompt)
                        .font(.title2.bold())
                        .foregroundColor(.black.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    
                    // MIC BUTTON – perfectly centered, never touches tab bar
                    Circle()
                        .fill(spokenText.contains(targetText) ? Color.green : Color(red: 0.4, green: 0.8, blue: 1.0))
                        .frame(width: 160, height: 160)
                        .overlay(
                            Image(systemName: "mic.fill")
                                .font(.system(size: 70, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 14, x: 0, y: 10)
                        .scaleEffect(speech.isRecording ? 1.15 : 1.0)
                        .animation(.spring(response: 0.35), value: speech.isRecording)
                        .gesture(
                            LongPressGesture(minimumDuration: 60)
                                .onChanged { _ in
                                    speech.startRecording { text in
                                        let cleanSpoken = text.lowercased()
                                            .replacingOccurrences(of: "[^a-z ]", with: "", options: .regularExpression)
                                        let cleanTarget = targetText.replacingOccurrences(of: "[^a-z ]", with: "", options: .regularExpression)
                                        
                                        if cleanSpoken.contains(cleanTarget) &&
                                           cleanSpoken.count > Int(Double(cleanTarget.count) * 0.6) {
                                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                                            withAnimation { vm.completeTask() }
                                            if vm.currentTask == 2 { showConfetti = true }
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    speech.stopRecording()
                                    spokenText = ""
                                }
                        )
                    
                    // Safe area buffer so mic never touches tab bar
                    Spacer()
                        .frame(height: 100)
                }
            }
            
            if showConfetti {
                ConfettiView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showConfetti = false
                        }
                    }
            }
        }
        .onAppear {
            speech.requestPermission()
        }
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.48
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        AVSpeechSynthesizer().speak(utterance)
    }
}
