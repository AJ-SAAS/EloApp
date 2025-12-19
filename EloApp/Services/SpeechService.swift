import Foundation
import Speech
import AVFoundation
import Combine

final class SpeechService: ObservableObject {

    @Published var isRecording = false

    // ✅ NEW
    @Published var micAuthorized = false
    @Published var speechAuthorized = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var completion: ((String) -> Void)?

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

    // ✅ NEW
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
        }

        audioEngine.prepare()
        try? audioEngine.start()
        isRecording = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    completion(result.bestTranscription.formattedString)
                }
            }

            if error != nil {
                self.stopRecording()
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}
