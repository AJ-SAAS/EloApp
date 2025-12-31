import SwiftUI

struct FreeTrialToggleView: View {
    let vm: OnboardingViewModel
    @State private var isEnabled = false
    @State private var showCheckmark = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Toggle Animation
            ZStack(alignment: isEnabled ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: 25)
                    .fill(isEnabled ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 120, height: 50)
                    .animation(.easeInOut(duration: 0.5), value: isEnabled)
                
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 46, height: 46)
                        .shadow(radius: 2)
                        .scaleEffect(isEnabled ? 1.1 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: isEnabled)
                    
                    if showCheckmark {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.green)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(2)
            }
            .onAppear {
                // Animate toggle to "on" state with bounce
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isEnabled = true
                    }
                    
                    // Show checkmark shortly after toggle
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            showCheckmark = true
                        }
                    }
                }
                
                // Automatically go to next page after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    vm.nextPage()
                }
            }
            
            // Text under toggle
            Text("7-Day Free Trial Enabled")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
}
