import SwiftUI

struct QuestionNotificationsView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 40) {
                Spacer().frame(height: 40)

                ZStack {
                    Circle()
                        .fill(Color.eloTeal.opacity(0.1))
                        .frame(width: 120, height: 120)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.eloTeal)
                }

                Text("I will remind you of your training time every day")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)

                Text("Allow notifications not to miss your practice time.")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding()

            Button { vm.previousPage() } label: {
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
