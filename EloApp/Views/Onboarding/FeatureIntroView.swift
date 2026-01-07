import SwiftUI

struct FeatureIntroView: View {
    let title: String
    let subtitle: String
    let imageName: String

    var body: some View {
        VStack(spacing: 0) {

            // ⬇️ Push image down slightly from top
            Spacer(minLength: 40)

            // IMAGE
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipped()
                .padding(.horizontal, 10)

            // ⬇️ More space between image and text
            Spacer(minLength: 32)

            // TEXT
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.leading)

                Text(subtitle)
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 24)

            // ⬇️ Less space before button so text sits lower
            Spacer(minLength: 24)
        }
        .padding(.bottom, 24)
    }
}
