import SwiftUI

struct GoalsConfirmationView: View {
    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                Spacer(minLength: 40)

                Image("eloob7")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding(.horizontal, 10)

                Spacer(minLength: 32)

                VStack(alignment: .leading, spacing: 14) {
                    Text("You're in the right place!")
                        .font(.system(size: 36, weight: .regular, design: .serif))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Many have started with the same goals — and Elo English got them there.")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 24)
            }
            .padding(.bottom, 24)

            Button { vm.previousPage() } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
            }
            .padding(.top, 50)
            .padding(.leading, 12)
        }
    }
}
