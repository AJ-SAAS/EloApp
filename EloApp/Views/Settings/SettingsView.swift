import SwiftUI
import FirebaseAuth
import AVFoundation
import Speech

// ⭐️ NEW: Difficulty enum (safe, standalone)
enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel

    // MARK: - Preferences
    @AppStorage("pref_notifications") private var notificationsEnabled = true
    @AppStorage("pref_sounds") private var soundsEnabled = true
    @AppStorage("selectedVoice") private var selectedVoice: String = VoiceOption.gbFemale.rawValue

    // ⭐️ NEW: Difficulty preference (defaults to current behavior = Hard)
    @AppStorage("selectedDifficulty") private var selectedDifficulty: String = Difficulty.hard.rawValue

    // MARK: - Permission State
    @State private var micAvailable = AVAudioSession.sharedInstance().recordPermission == .granted
    @State private var speechAvailable = SFSpeechRecognizer.authorizationStatus() == .authorized

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {

                    // MARK: - Account Info
                    VStack(spacing: 8) {
                        Text("Account")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        if let email = Auth.auth().currentUser?.email {
                            HStack {
                                Text("Email")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(email)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(14)
                            .padding(.horizontal)
                        } else {
                            Text("Not signed in")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                    }

                    // MARK: - Preferences
                    VStack(spacing: 8) {
                        Text("Preferences")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        VStack(spacing: 10) {
                            Toggle("Daily Notifications", isOn: $notificationsEnabled)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(14)
                                .padding(.horizontal)

                            Toggle("Enable Sounds", isOn: $soundsEnabled)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(14)
                                .padding(.horizontal)

                            // Voice Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Voice")
                                    .font(.headline)

                                Picker("Select Voice", selection: $selectedVoice) {
                                    ForEach(VoiceOption.allCases, id: \.rawValue) {
                                        Text($0.rawValue).tag($0.rawValue)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(14)
                            .padding(.horizontal)

                            // ⭐️ NEW: Difficulty Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Difficulty")
                                    .font(.headline)

                                Picker("Select Difficulty", selection: $selectedDifficulty) {
                                    ForEach(Difficulty.allCases, id: \.rawValue) {
                                        Text($0.rawValue).tag($0.rawValue)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(14)
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - Voice Access (Apple Review Friendly)
                    VStack(spacing: 10) {
                        Text("Voice Access")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "mic.fill")
                                Text("Microphone")
                                Spacer()
                                statusView(isEnabled: micAvailable)
                            }

                            HStack {
                                Image(systemName: "waveform")
                                Text("Speech Recognition")
                                Spacer()
                                statusView(isEnabled: speechAvailable)
                            }

                            if !micAvailable || !speechAvailable {
                                Button("Open Settings") {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .font(.footnote.bold())
                                .padding(.top, 6)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(14)
                        .padding(.horizontal)
                    }

                    // MARK: - General
                    VStack(spacing: 8) {
                        Text("General")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        VStack(spacing: 10) {
                            SettingsRow(title: "Privacy Policy") {
                                openLink(url: "https://your-privacy-policy.com")
                            }
                            SettingsRow(title: "Terms of Use") {
                                openLink(url: "https://your-terms.com")
                            }
                            SettingsRow(title: "Give Feedback") {
                                openLink(url: "mailto:feedback@yourapp.com")
                            }
                            SettingsRow(title: "Contact Us") {
                                openLink(url: "mailto:support@yourapp.com")
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Account Actions
                    VStack(spacing: 8) {
                        Text("Account Actions")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        VStack(spacing: 10) {
                            Button("Delete Account") {
                                print("Delete account tapped")
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(14)

                            Button("Restore Purchases") {
                                print("Restore purchases tapped")
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(14)

                            Button("Sign Out") {
                                authVM.signOut()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Settings")
            .onAppear {
                updatePermissions()
                NotificationCenter.default.addObserver(
                    forName: UIApplication.didBecomeActiveNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    updatePermissions()
                }
            }
        }
    }

    // MARK: - Helpers
    private func updatePermissions() {
        micAvailable = AVAudioSession.sharedInstance().recordPermission == .granted
        speechAvailable = SFSpeechRecognizer.authorizationStatus() == .authorized
    }

    private func statusView(isEnabled: Bool) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isEnabled ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            Text(isEnabled ? "Enabled" : "Disabled")
                .foregroundColor(.gray)
        }
    }

    private func openLink(url: String) {
        if let link = URL(string: url) {
            UIApplication.shared.open(link)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(14)
        }
    }
}
