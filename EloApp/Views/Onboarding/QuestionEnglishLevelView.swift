import SwiftUI

struct QuestionEnglishLevelView: View {
    @ObservedObject var vm: OnboardingViewModel

    let levelOptions = [
        ("Beginner", "Just starting"),
        ("Elementary", "Simple phrases"),
        ("Intermediate", "Daily chats"),
        ("Upper-Intermediate", "Most topics"),
        ("Advanced", "Very fluent"),
        ("Near-Fluent", "Like a native")
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 30) {
                Spacer().frame(height: 60)

                Text("What is your level of English?")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(levelOptions, id: \.0) { level, description in
                            Button {
                                vm.englishLevel = level
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(level)
                                            .font(.system(size: 20, weight: .semibold))
                                            .fixedSize(horizontal: false, vertical: true)

                                        Text(description)
                                            .font(.system(size: 15, weight: .regular))
                                            .foregroundColor(vm.englishLevel == level
                                                ? .white.opacity(0.85)
                                                : .secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }

                                    Spacer()

                                    if vm.englishLevel == level {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(vm.englishLevel == level
                                            ? Color.eloTeal
                                            : Color.eloTeal.opacity(0.07))
                                )
                                .foregroundColor(vm.englishLevel == level ? .white : .primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            vm.englishLevel == level
                                                ? Color.eloTeal
                                                : Color.eloTeal.opacity(0.15),
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.horizontal)

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
