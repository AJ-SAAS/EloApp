import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationView {
            Form {
                
                Section("Account") {
                    if let email = Auth.auth().currentUser?.email {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Not signed in")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task {
                            await authVM.signOut()
                        }
                    } label: {
                        Text("Sign Out")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
