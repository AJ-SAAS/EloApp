import SwiftUI

struct ScientificMethodView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                Spacer().frame(height: 20)

                // TITLE
                Text("The Elo 3-Stage Speaking Loop")
                    .font(.system(size: 34, weight: .regular, design: .serif))

                // SUBTITLE
                Text("A proven way to remember English words faster.")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)

                Spacer().frame(height: 10)

                // STEP 1
                MethodBlock(
                    step: 1,
                    icon: "mic.fill",
                    color: .blue,
                    title: "Speak",
                    description: "Say the word out loud.",
                    linkText: "Production Effect",
                    url: "https://en.wikipedia.org/wiki/Production_effect"
                )

                // STEP 2
                MethodBlock(
                    step: 2,
                    icon: "bubble.left.and.bubble.right.fill",
                    color: .green,
                    title: "Repeat",
                    description: "Speak the full sentence.",
                    linkText: "Shadowing",
                    url: "https://en.wikipedia.org/wiki/Speech_shadowing"
                )

                // STEP 3
                MethodBlock(
                    step: 3,
                    icon: "brain.head.profile",
                    color: .purple,
                    title: "Remember",
                    description: "Say the sentence from memory.",
                    linkText: "Retrieval Practice",
                    url: "https://www.retrievalpractice.org/why-it-works"
                )

                Spacer().frame(height: 20)

                // CREDIBILITY TEXT
                Text("Inspired by research in language learning and cognitive science.")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }
}


// MARK: - Method Block

struct MethodBlock: View {

    let step: Int
    let icon: String
    let color: Color
    let title: String
    let description: String
    let linkText: String
    let url: String

    var body: some View {

        HStack(alignment: .top, spacing: 16) {

            // STEP NUMBER CIRCLE
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Text("\(step)")
                    .font(.headline.bold())
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 10) {

                // TITLE + ICON
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(color)

                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                }

                // DESCRIPTION
                Text(description)
                    .font(.system(size: 18))

                // CLICKABLE RESEARCH LINK
                Link(destination: URL(string: url)!) {
                    HStack(spacing: 4) {
                        Text(linkText)
                        Image(systemName: "arrow.up.right.square")
                    }
                    .font(.system(size: 15, weight: .semibold))
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.06))
        .cornerRadius(16)
    }
}
