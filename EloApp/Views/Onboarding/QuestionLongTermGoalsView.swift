import SwiftUI

struct QuestionLongTermGoalsView: View {
    @ObservedObject var vm: OnboardingViewModel

    let goalOptions = [
        "💼 Get a better job",
        "🌍 Travel the world",
        "🎓 Pass an English exam",
        "🤔 Not sure yet"
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 30) {
                Spacer().frame(height: 60)

                Text("What are your long-term goals for learning English?")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    ForEach(goalOptions, id: \.self) { goal in
                        Button {
                            vm.longTermGoal = goal
                        } label: {
                            HStack {
                                Text(goal)
                                    .font(.system(size: 20, weight: .semibold))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if vm.longTermGoal == goal {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                }
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(vm.longTermGoal == goal
                                        ? Color.eloTeal
                                        : Color.eloTeal.opacity(0.07))
                            )
                            .foregroundColor(vm.longTermGoal == goal ? .white : .primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        vm.longTermGoal == goal
                                            ? Color.eloTeal
                                            : Color.eloTeal.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal)

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
