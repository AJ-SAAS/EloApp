// Views/Onboarding/WelcomeView.swift

import SwiftUI

struct WelcomeView: View {
    let vm: OnboardingViewModel
    
    var body: some View {
        VStack {
            Spacer()  // Pushes content to bottom third
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to Elo!")
                    .font(.system(size: 48, weight: .bold))  // ← Increased size (bigger than .largeTitle)
                    .multilineTextAlignment(.leading)
                
                Text("Boost your language skills with Elo effortlessly anytime, anywhere.")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal)
            
            Spacer().frame(height: 60)  // Larger gap between subtitle and "Log in"
            
            VStack(spacing: 16) {
                Text("Log in")
                    .font(.title3.bold())
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)  // Centers the text horizontally
                
                Button("Let's Go") {
                    vm.nextPage()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal)
            
            Spacer().frame(height: 40)  // Bottom safe area padding
        }
        .padding()
    }
}
