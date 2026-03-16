import SwiftUI

struct FeatureIntroView: View {
    let title: String
    let subtitle: String
    let imageName: String

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipped()
                .padding(.horizontal, 10)

            Spacer(minLength: 32)

            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 24)
        }
        .padding(.bottom, 24)
    }
}
