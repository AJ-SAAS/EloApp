import SwiftUI

struct QuestionDailyGoalView: View {
    @ObservedObject var vm: OnboardingViewModel

    let goals = ["5 min / day", "10 min / day", "15 min / day", "30 min / day", "60 min / day"]

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 30) {
                Spacer().frame(height: 40)

                Text("What's your daily practice goal?")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    ForEach(goals, id: \.self) { goal in
                        Button {
                            vm.dailyGoal = goal
                        } label: {
                            HStack {
                                Text(goal)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(vm.dailyGoal == goal ? .white : .primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)

                                if vm.dailyGoal == goal {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(vm.dailyGoal == goal
                                        ? Color.eloTeal
                                        : Color.eloTeal.opacity(0.07))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        vm.dailyGoal == goal
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
            .padding()

            Button { vm.previousPage() } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
            }
        }
    }
}
