// Views/Onboarding/FreeTrialToggleView.swift

import SwiftUI

struct FreeTrialToggleView: View {
    let vm: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Replace with your animated toggle GIF or Lottie later
            Image("free_trial_toggle") // Placeholder asset
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            
            Text("7-Day Free Trial Enabled")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                vm.nextPage()
            }
        }
    }
}
