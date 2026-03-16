import SwiftUI
import AVFAudio
import Speech
import FirebaseAuth
import FirebaseFirestore
import RevenueCat

// MARK: - Difficulty Enum
enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

// MARK: - View Modifiers
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
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.eloTeal)
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
        .padding(.horizontal)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel
    @StateObject private var progress = ProgressTracker.shared

    // Preferences
    @AppStorage("pref_notifications") private var notificationsEnabled = true
    @AppStorage("pref_sounds") private var soundsEnabled = true
    @AppStorage("selectedVoice") private var selectedVoice: String = VoiceOption.gbFemale.rawValue
    @AppStorage("selectedDifficulty") private var selectedDifficulty: String = Difficulty.medium.rawValue

    // Permissions
    @State private var micAvailable =
        AVAudioApplication.shared.recordPermission == .granted
    @State private var speechAvailable =
        SFSpeechRecognizer.authorizationStatus() == .authorized

    // Delete / reset password flow
    @State private var showDeleteConfirm = false
    @State private var showPasswordPrompt = false
    @State private var showResetPasswordPrompt = false
    @State private var password = ""
    @State private var newPassword = ""

    // ✅ Single source of truth for premium status
    private var hasPremium: Bool {
        purchaseVM.hasPremiumAccess() || progress.hasPremiumAccess
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {

                    // MARK: - Account
                    VStack(spacing: 8) {
                        sectionTitle("Account")

                        if let email = authVM.userEmail {
                            HStack {
                                Text("Email")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(email)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(14)
                            .padding(.horizontal)

                            SettingsRow(title: "Reset Password") {
                                showResetPasswordPrompt = true
                            }
                        } else {
                            Text("Not signed in")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                    }

                    // MARK: - Preferences
                    VStack(spacing: 8) {
                        sectionTitle("Preferences")

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
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .font(.footnote.bold())
                                .padding(.top, 6)
                            }
                        }
                        .settingsGroup()
                    }

                    // MARK: - Subscriptions
                    VStack(spacing: 12) {
                        sectionTitle("Subscriptions")

                        if hasPremium {
                            // ✅ Show premium badge instead of upgrade button
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.eloTeal)
                                    .font(.system(size: 20))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Elo Premium Active")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.primary)
                                    Text("You have full access")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.eloTeal.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.eloTeal.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(14)
                            .padding(.horizontal)

                        } else {
                            Button("👑 Get Elo Premium") {
                                Task {
                                    if let package = purchaseVM.offerings?.current?.availablePackages.first {
                                        let success = await purchaseVM.purchase(package: package)
                                        if success {
                                            ProgressTracker.shared.hasPremiumAccess = true
                                        }
                                    } else {
                                        print("⚠️ No package available to purchase")
                                    }
                                }
                            }
                            .primaryButton()
                            .padding(.horizontal)
                        }

                        SettingsRow(title: "Manage Subscription") {
                            openLink("https://apps.apple.com/account/subscriptions")
                        }

                        SettingsRow(title: "Restore Subscription") {
                            Task {
                                await purchaseVM.restorePurchases()
                                if purchaseVM.hasPremiumAccess() {
                                    ProgressTracker.shared.hasPremiumAccess = true
                                }
                            }
                        }
                    }

                    // MARK: - General
                    VStack(spacing: 8) {
                        sectionTitle("General")

                        SettingsRow(title: "Website") {
                            openLink("https://www.tryeloenglish.xyz/")
                        }

                        SettingsRow(title: "Privacy Policy") {
                            openLink("https://www.tryeloenglish.xyz/privacy")
                        }

                        SettingsRow(title: "Terms of Use") {
                            openLink("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
                        }

                        SettingsRow(title: "Contact Us") {
                            openLink("mailto:tryeloenglish@gmail.com")
                        }

                        SettingsRow(title: "Share Feedback") {
                            openLink("mailto:tryeloenglish@gmail.com?subject=Feedback%20on%20Elo%20App")
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Account Actions
                    VStack(spacing: 12) {
                        sectionTitle("Account Actions")

                        Button("Sign Out") {
                            authVM.signOut()
                        }
                        .primaryButton()
                        .padding(.horizontal)

                        Button("Delete Account") {
                            showDeleteConfirm = true
                        }
                        .destructiveButton()
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Settings")
            .onAppear {
                updatePermissions()
                purchaseVM.fetchCustomerInfo() // ✅ refresh purchase state on appear
            }

            // MARK: - Alerts
            .alert("Delete Account?",
                   isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    Task {
                        await authVM.deleteAccount {
                            showPasswordPrompt = true
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and data. This action cannot be undone.")
            }

            .alert("Confirm Password",
                   isPresented: $showPasswordPrompt) {
                SecureField("Password", text: $password)
                Button("Confirm Delete", role: .destructive) {
                    Task {
                        await authVM.deleteAccount(password: password)
                        password = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    password = ""
                }
            } message: {
                Text("For security reasons, please re-enter your password.")
            }

            .alert("Reset Password",
                   isPresented: $showResetPasswordPrompt) {
                SecureField("New Password", text: $newPassword)
                Button("Confirm") {
                    Task {
                        if let user = Auth.auth().currentUser {
                            do {
                                try await user.updatePassword(to: newPassword)
                                print("✅ Password updated")
                                newPassword = ""
                            } catch {
                                print("❌ Failed to update password:", error.localizedDescription)
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) {
                    newPassword = ""
                }
            } message: {
                Text("Enter a new password to update your account.")
            }
        }
    }

    // MARK: - Helpers
    private func updatePermissions() {
        micAvailable = AVAudioApplication.shared.recordPermission == .granted
        speechAvailable = SFSpeechRecognizer.authorizationStatus() == .authorized
    }

    private func openLink(_ url: String) {
        if let link = URL(string: url) {
            UIApplication.shared.open(link)
        }
    }

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
            Circle()
                .fill(enabled ? Color.eloTeal : .red)
                .frame(width: 12, height: 12)
        }
    }

    private func pickerSection(
        title: String,
        selection: Binding<String>,
        options: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

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
