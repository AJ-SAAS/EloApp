import SwiftUI

struct GoalsConfirmationView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 0) {

            // Push image down slightly from top
            Spacer(minLength: 40)

            // IMAGE
            Image("eloob7") // Replace with your actual image name
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipped()
                .padding(.horizontal, 10)

            // More space between image and text
            Spacer(minLength: 32)

            // TEXT
            VStack(alignment: .leading, spacing: 14) {
                Text("You're in the right place!")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.leading)

                Text("Many have started with the same goals — and Elo English got them there.")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 24)

            // Less space before button so text sits lower
            Spacer(minLength: 24)
        }
        .padding(.bottom, 24)
    }
}
