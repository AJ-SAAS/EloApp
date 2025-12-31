import SwiftUI

struct QuestionEnglishLevelView: View {
    @ObservedObject var vm: OnboardingViewModel

    let levels = [
        "Beginner",
        "Pre-Intermediate",
        "Intermediate",
        "Upper-Intermediate",
        "Advanced",
        "Proficient"
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {

            VStack(spacing: 30) {

                Spacer().frame(height: 40)

                Text("What is your level of English?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    ForEach(levels, id: \.self) { level in
                        Button {
                            vm.englishLevel = level
                        } label: {
                            Text(level)
                                .font(.title2.bold())
                                .foregroundColor(vm.englishLevel == level ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(vm.englishLevel == level ? Color.purple : Color.gray.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()

            // Back button
            Button {
                vm.previousPage()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .padding()
            }
        }
    }
}
