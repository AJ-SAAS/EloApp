// Views/Onboarding/ClaimRewardView.swift

import SwiftUI

struct ClaimRewardView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Spacer()
                Button {
                    vm.showExitConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.3)))
                }
                .padding()
            }
            
            Text("Claim Your Reward")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Text("90% OFF")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.yellow)
            
            Text("Save $5.73 per week")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("$6.49 per week")
                .font(.title3)
                .strikethrough()
                .foregroundColor(.white.opacity(0.7))
            
            Text("$1.12 per week")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Text("$57.99 Billed yearly")
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
            
            Button("Claim Reward") {
                // Future: Connect to RevenueCat purchase
                print("Claim Reward tapped")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color.red.ignoresSafeArea())
        .alert("Are you sure to leave?", isPresented: $vm.showExitConfirmation) {
            Button("Claim Reward", role: .cancel) { }
            Button("Leave", role: .destructive) {
                vm.currentPage = .authSetup
            }
        } message: {
            Text("This is a one-time offer, you will lose this special discount if you leave now.")
        }
    }
}
