// Views/Onboarding/QuestionNotificationsView.swift

import SwiftUI

struct QuestionNotificationsView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "bell.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("I will remind you of your training time every day")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Allow notifications not to miss your practice time.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await vm.requestNotificationPermission()
            }
            // Auto-advance after a short delay to let user read
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                vm.nextPage()
            }
        }
    }
}
