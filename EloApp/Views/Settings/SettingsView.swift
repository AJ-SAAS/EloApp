import SwiftUI
import AVFoundation
import Speech

// MARK: - Difficulty Enum
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
    @AppStorage("selectedDifficulty") private var selectedDifficulty: String = Difficulty.hard.rawValue

    // MARK: - Permission State
    @State private var micAvailable =
        AVAudioSession.sharedInstance().recordPermission == .granted
    @State private var speechAvailable =
        SFSpeechRecognizer.authorizationStatus() == .authorized

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {

                    // MARK: - Account Info
                    VStack(spacing: 8) {
                        sectionTitle("Account")

                        if let email = authVM.userEmail {
                            HStack {
                                Text("Email")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(email)
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
                        sectionTitle("Preferences")

                        VStack(spacing: 10) {
                            Toggle("Daily Notifications", isOn: $notificationsEnabled)
                                .settingsRow()

                            Toggle("Enable Sounds", isOn: $soundsEnabled)
                                .settingsRow()

                            pickerSection(
                                title: "Voice",
                                selection: $selectedVoice,
                                options: VoiceOption.allCases.map { $0.rawValue }
                            )

                            pickerSection(
                                title: "Difficulty",
                                selection: $selectedDifficulty,
                                options: Difficulty.allCases.map { $0.rawValue }
                            )
                        }
                    }

                    // MARK: - Voice Access
                    VStack(spacing: 10) {
                        sectionTitle("Voice Access")

                        VStack(spacing: 12) {
                            permissionRow(
                                icon: "mic.fill",
                                title: "Microphone",
                                enabled: micAvailable
                            )

                            permissionRow(
                                icon: "waveform",
                                title: "Speech Recognition",
                                enabled: speechAvailable
                            )

                            if !micAvailable || !speechAvailable {
                                Button("Open Settings") {
                                    if let url = URL(
                                        string: UIApplication.openSettingsURLString
                                    ) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .font(.footnote.bold())
                                .padding(.top, 6)
                            }
                        }
                        .settingsGroup()
                    }

                    // MARK: - General
                    VStack(spacing: 8) {
                        sectionTitle("General")

                        VStack(spacing: 10) {
                            SettingsRow(title: "Privacy Policy") {
                                openLink("https://your-privacy-policy.com")
                            }
                            SettingsRow(title: "Terms of Use") {
                                openLink("https://your-terms.com")
                            }
                            SettingsRow(title: "Give Feedback") {
                                openLink("mailto:feedback@yourapp.com")
                            }
                            SettingsRow(title: "Contact Us") {
                                openLink("mailto:support@yourapp.com")
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Account Actions
                    VStack(spacing: 8) {
                        sectionTitle("Account Actions")

                        VStack(spacing: 10) {
                            Button("Delete Account") {
                                // TODO: Add delete flow (reauth required)
                            }
                            .destructiveButton()

                            Button("Restore Purchases") {
                                // TODO: Restore purchases
                            }
                            .secondaryButton()

                            Button("Sign Out") {
                                authVM.signOut()
                            }
                            .primaryButton()
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Settings")
            .onAppear(perform: updatePermissions)
            .onReceive(
                NotificationCenter.default.publisher(
                    for: UIApplication.didBecomeActiveNotification
                )
            ) { _ in
                updatePermissions()
            }
        }
    }

    // MARK: - Helpers

    private func updatePermissions() {
        micAvailable =
            AVAudioSession.sharedInstance().recordPermission == .granted
        speechAvailable =
            SFSpeechRecognizer.authorizationStatus() == .authorized
    }

    private func openLink(_ url: String) {
        if let link = URL(string: url) {
            UIApplication.shared.open(link)
        }
    }

    // MARK: - UI Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title2.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }

    private func permissionRow(
        icon: String,
        title: String,
        enabled: Bool
    ) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
            statusView(enabled)
        }
    }

    private func statusView(_ enabled: Bool) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(enabled ? .green : .red)
                .frame(width: 12, height: 12)
            Text(enabled ? "Enabled" : "Disabled")
                .foregroundColor(.gray)
        }
    }

    private func pickerSection(
        title: String,
        selection: Binding<String>,
        options: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)

            Picker(title, selection: selection) {
                ForEach(options, id: \.self) {
                    Text($0).tag($0)
                }
            }
            .pickerStyle(.segmented)
        }
        .settingsGroup()
    }
}

// MARK: - Reusable Modifiers

extension View {
    func settingsGroup() -> some View {
        self
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(14)
            .padding(.horizontal)
    }

    func settingsRow() -> some View {
        self
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(14)
            .padding(.horizontal)
    }

    func primaryButton() -> some View {
        self
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .cornerRadius(14)
    }

    func secondaryButton() -> some View {
        self
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(14)
    }

    func destructiveButton() -> some View {
        self
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(14)
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
