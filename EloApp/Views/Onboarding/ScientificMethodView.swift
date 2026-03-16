import SwiftUI

// MARK: - Colors
private extension Color {

    // Per-step colors
    static let stepBlue       = Color(red: 0.145, green: 0.388, blue: 0.922)  // #2563EB
    static let stepBlueLight  = Color(red: 0.937, green: 0.965, blue: 1.0)    // #EFF6FF
    static let stepBlueBorder = Color(red: 0.749, green: 0.859, blue: 0.996)  // #BFDBFE

    static let stepGreen      = Color(red: 0.086, green: 0.639, blue: 0.290)  // #16A34A
    static let stepGreenLight = Color(red: 0.941, green: 0.992, blue: 0.953)  // #F0FDF4
    static let stepGreenBorder = Color(red: 0.525, green: 0.937, blue: 0.675) // #86EFAC

    static let stepPurple      = Color(red: 0.576, green: 0.200, blue: 0.918) // #9333EA
    static let stepPurpleLight = Color(red: 0.980, green: 0.961, blue: 1.0)   // #FAF5FF
    static let stepPurpleBorder = Color(red: 0.847, green: 0.706, blue: 0.996)// #D8B4FE
}

struct ScientificMethodView: View {

    @ObservedObject var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                Spacer().frame(height: 20)

                // 🔹 Personalized Greeting
                if !vm.userName.isEmpty {
                    Text("Awesome, great to meet you, \(vm.userName)!")
                        .font(.system(size: 28, weight: .medium, design: .serif))
                        .foregroundColor(.primary)
                        .padding(.bottom, 6)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Did you know…")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // BADGE
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.eloTeal)
                    Text("SCIENCE-BACKED")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.039, green: 0.478, blue: 0.329))
                        .kerning(0.5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.eloTealLight))
                .overlay(Capsule().stroke(Color.eloTeal.opacity(0.2), lineWidth: 0.5))
                .padding(.bottom, 14)

                // TITLE
                Text("The Elo 3-Stage\nSpeaking Loop")
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .padding(.bottom, 10)
                    .fixedSize(horizontal: false, vertical: true)

                // SUBTITLE
                Text("How you will learn every word.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 28)
                    .fixedSize(horizontal: false, vertical: true)

                // STEP 1
                MethodBlock(
                    step: 1,
                    icon: "mic.fill",
                    color: .stepBlue,
                    lightColor: .stepBlueLight,
                    borderColor: .stepBlueBorder,
                    title: "Speak",
                    emoji: "🎤",
                    description: "Say the word out loud.",
                    linkText: "Production Effect",
                    url: "https://en.wikipedia.org/wiki/Production_effect"
                )

                // CONNECTOR
                StepConnector(topColor: .stepBlue, bottomColor: .stepGreen)

                // STEP 2
                MethodBlock(
                    step: 2,
                    icon: "bubble.left.and.bubble.right.fill",
                    color: .stepGreen,
                    lightColor: .stepGreenLight,
                    borderColor: .stepGreenBorder,
                    title: "Repeat",
                    emoji: "🔁",
                    description: "Speak the full sentence.",
                    linkText: "Shadowing",
                    url: "https://en.wikipedia.org/wiki/Speech_shadowing"
                )

                // CONNECTOR
                StepConnector(topColor: .stepGreen, bottomColor: .stepPurple)

                // STEP 3
                MethodBlock(
                    step: 3,
                    icon: "brain.head.profile",
                    color: .stepPurple,
                    lightColor: .stepPurpleLight,
                    borderColor: .stepPurpleBorder,
                    title: "Remember",
                    emoji: "🧠",
                    description: "Say it from memory.",
                    linkText: "Retrieval Practice",
                    url: "https://www.retrievalpractice.org/why-it-works"
                )

                Spacer().frame(height: 20)

                // CREDIBILITY TEXT
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 13))
                        .foregroundColor(.eloTeal)
                    Text("Based on real science. Tap any link to learn more.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.white.ignoresSafeArea())
    }
}


// MARK: - Step Connector

struct StepConnector: View {
    let topColor: Color
    let bottomColor: Color

    var body: some View {
        HStack(spacing: 0) {
            HStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [topColor.opacity(0.35), bottomColor.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2, height: 24)
                    .padding(.leading, 19)
                Spacer()
            }

            Spacer()
        }
        .overlay(
            Text("then")
                .font(.system(size: 12))
                .foregroundColor(Color(.tertiaryLabel))
                .padding(.leading, 56),
            alignment: .leading
        )
        .frame(height: 24)
        .padding(.vertical, 4)
    }
}


// MARK: - Method Block

struct MethodBlock: View {

    let step: Int
    let icon: String
    let color: Color
    let lightColor: Color
    let borderColor: Color
    let title: String
    let emoji: String
    let description: String
    let linkText: String
    let url: String

    var body: some View {

        HStack(alignment: .top, spacing: 16) {

            // STEP CIRCLE
            ZStack {
                Circle()
                    .fill(lightColor)
                    .frame(width: 40, height: 40)
                Circle()
                    .stroke(color, lineWidth: 2)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 0) {

                // STEP BADGE
                Text("STEP \(step)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
                    .kerning(0.5)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(color.opacity(0.12)))
                    .padding(.bottom, 6)

                // TITLE + EMOJI
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(emoji)
                        .font(.system(size: 18))
                }
                .padding(.bottom, 4)

                // DESCRIPTION
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                    .fixedSize(horizontal: false, vertical: true)

                // CLICKABLE RESEARCH LINK
                Link(destination: URL(string: url)!) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .semibold))
                        Text(linkText)
                            .font(.system(size: 12, weight: .medium))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 0.5)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(lightColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: 0.5)
        )
    }
}
