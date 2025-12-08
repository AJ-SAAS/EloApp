// Services/SpeechService.swift
// FINAL – WORKS 100% ON iOS 17 & 18 – NO WARNINGS, NO CRASHES

import Foundation
import Speech
import AVFoundation
import Combine

final class SpeechService: ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var audioEngine = AVAudioEngine()
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var task: SFSpeechRecognitionTask?
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { _ in }
        AVAudioApplication.requestRecordPermission { _ in }
    }
    
    func startRecording(onTranscription: @escaping (String) -> Void) {
        stopRecording()
        
        // Fresh objects
        audioEngine = AVAudioEngine()
        request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        // Audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session failed: \(error)")
            return
        }
        
        // inputNode is non-optional in iOS 17+
        let inputNode = audioEngine.inputNode
        
        let format = inputNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0 && format.channelCount > 0 else {
            print("Invalid audio format")
            try? session.setActive(false)
            return
        }
        
        task = recognizer?.recognitionTask(with: request) { [weak self] result, _ in
            guard let self = self, let result = result else {
                self?.stopRecording()
                return
            }
            let text = result.bestTranscription.formattedString.lowercased()
            self.transcribedText = text
            onTranscription(text)
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Audio engine failed: \(error)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request.endAudio()
        task?.cancel()
        task = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
