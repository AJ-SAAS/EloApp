import SwiftUI

struct PaywallView: View {
    let vm: OnboardingViewModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    vm.skipPaywall() // For now: skip to main app
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .padding()
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
                .padding()
            }
            
            Spacer()
            
            Text("Unlock Premium")
                .font(.largeTitle.bold())
            
            Text("Get unlimited access to personalized plans, daily lessons, and more.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
            // Placeholder subscription options
            VStack(spacing: 16) {
                Text("7-Day Free Trial")
                    .font(.headline)
                Text("$57.99 / year")
                    .font(.title.bold())
                Text("Then $6.49/week")
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button("Start Free Trial") {
                // Later: trigger purchase
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
            
            Spacer()
        }
    }
}
