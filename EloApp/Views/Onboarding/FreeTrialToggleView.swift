import SwiftUI

struct FreeTrialToggleView: View {
    let vm: OnboardingViewModel
    @State private var isEnabled = false
    @State private var showCheckmark = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

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

            Text("7-Day Free Trial Enabled")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)

            Spacer()
        }
        .onAppear {
            isEnabled = false
            showCheckmark = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { isEnabled = true }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeIn(duration: 0.3)) { showCheckmark = true }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                // Only advance if this toggle is actually the current page
                if vm.currentPage == .freeTrialToggle1 || vm.currentPage == .freeTrialToggle2 {
                    vm.nextPage()
                }
            }
        }
    }
}
