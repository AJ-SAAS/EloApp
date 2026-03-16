import SwiftUI

struct QuestionShortTermGoalsView: View {
    @ObservedObject var vm: OnboardingViewModel

    let goalOptions = [
        "🗣️ Speak more confidently",
        "✅ Make fewer mistakes",
        "🔊 Improve my pronunciation",
        "📚 Build my vocabulary",
        "😌 Reduce speaking anxiety",
        "✍️ Fix grammar errors",
        "🌊 Sound more fluent",
        "😊 Feel less embarrassed"
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 30) {
                Spacer().frame(height: 60)

                Text("What do you want to achieve with Elo English?")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(goalOptions, id: \.self) { goal in
                            Button {
                                if vm.shortTermGoals.contains(goal) {
                                    vm.shortTermGoals.remove(goal)
                                } else {
                                    vm.shortTermGoals.insert(goal)
                                }
                            } label: {
                                HStack {
                                    Text(goal)
                                        .font(.system(size: 20, weight: .semibold))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: true)

                                    if vm.shortTermGoals.contains(goal) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                    }
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(vm.shortTermGoals.contains(goal)
                                            ? Color.eloTeal
                                            : Color.eloTeal.opacity(0.07))
                                )
                                .foregroundColor(vm.shortTermGoals.contains(goal) ? .white : .primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            vm.shortTermGoals.contains(goal)
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
