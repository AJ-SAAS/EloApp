import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    // MARK: - Preferences
    @AppStorage("pref_notifications") private var notificationsEnabled = true
    @AppStorage("pref_sounds") private var soundsEnabled = true
    @AppStorage("selectedVoice") private var selectedVoice: String = VoiceOption.gbFemale.rawValue

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
                            Toggle(isOn: $notificationsEnabled) {
                                Text("Daily Notifications")
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(14)
                            .padding(.horizontal)

                            Toggle(isOn: $soundsEnabled) {
                                Text("Enable Sounds")
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(14)
                            .padding(.horizontal)

                            // Voice Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Voice")
                                    .foregroundColor(.black)
                                    .font(.headline)
                                
                                Picker("Select Voice", selection: $selectedVoice) {
                                    ForEach(VoiceOption.allCases, id: \.rawValue) { option in
                                        Text(option.rawValue).tag(option.rawValue)
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

                    // MARK: - General
                    VStack(spacing: 8) {
                        Text("General")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        VStack(spacing: 10) {
                            SettingsRow(title: "Privacy Policy") { openLink(url: "https://your-privacy-policy.com") }
                            SettingsRow(title: "Terms of Use") { openLink(url: "https://your-terms.com") }
                            SettingsRow(title: "Give Feedback") { openLink(url: "mailto:feedback@yourapp.com") }
                            SettingsRow(title: "Contact Us") { openLink(url: "mailto:support@yourapp.com") }
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
                            Button(action: {
                                print("Delete account tapped")
                            }) {
                                Text("Delete Account")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(14)
                            }

                            Button(action: {
                                print("Restore purchases tapped")
                            }) {
                                Text("Restore Purchases")
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(14)
                            }

                            Button(action: {
                                authVM.signOut()
                            }) {
                                Text("Sign Out")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationTitle("Settings")
        }
    }

    // MARK: - Helpers
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
                    .foregroundColor(.black)
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

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
 
