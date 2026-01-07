import SwiftUI

struct QuestionNotificationsView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 40) {
                Spacer().frame(height: 40)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
                
                Text("I will remind you of your training time every day")
                    .font(.system(size: 20, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Text("Allow notifications not to miss your practice time.")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            
            Button {
                vm.previousPage()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .padding()
            }
        }
        .onAppear {
            Task { await vm.requestNotificationPermission() }
        }
    }
}
