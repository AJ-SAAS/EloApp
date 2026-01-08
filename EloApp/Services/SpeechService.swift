import Foundation
import Speech
import AVFoundation
import Combine

final class SpeechService: ObservableObject {

    @Published var isRecording = false
    @Published var micAuthorized = false
    @Published var speechAuthorized = false
    @Published var currentAmplitude: Float = 0.0

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var completion: ((String) -> Void)?

    private var silenceTimer: Timer?

    // MARK: - Permissions

    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.speechAuthorized = (status == .authorized)
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.micAuthorized = granted
            }
        }
    }

    var micAvailable: Bool {
        micAuthorized && speechAuthorized
    }

    // MARK: - Recording

    func startRecording(completion: @escaping (String) -> Void) {
        guard micAvailable else {
            print("❌ Mic or Speech permission not granted")
            return
        }

        self.completion = completion
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.duckOthers, .defaultToSpeaker])
        try? audioSession.setActive(true)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.recognitionRequest?.append(buffer)

            // Update amplitude
            self.updateAmplitude(buffer: buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        isRecording = true

        // Reset silence timer
        resetSilenceTimer()

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    completion(result.bestTranscription.formattedString)
                    self.resetSilenceTimer()
                }
            }

            if error != nil {
                self.stopRecording()
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        DispatchQueue.main.async {
            self.isRecording = false
            self.currentAmplitude = 0.0
        }

        silenceTimer?.invalidate()
        silenceTimer = nil
    }

    // MARK: - Amplitude / Waveform
    private func updateAmplitude(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += channelData[i] * channelData[i]
        }
        let rms = sqrt(sum / Float(frameLength))
        DispatchQueue.main.async {
            self.currentAmplitude = rms
        }
    }

    // MARK: - Auto stop after silence
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.stopRecording()
        }
    }
}
