import SwiftUI

struct QuestionDailyGoalView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    let goals = ["5 min / day", "10 min / day", "15 min / day", "30 min / day", "60 min / day"]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 30) {
                Spacer().frame(height: 40)
                
                Text("What's your daily practice goal?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ForEach(goals, id: \.self) { goal in
                    Button {
                        vm.dailyGoal = goal
                    } label: {
                        Text(goal)
                            .font(.title2.bold())
                            .foregroundColor(vm.dailyGoal == goal ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(vm.dailyGoal == goal ? Color.purple : Color.gray.opacity(0.1))
                            )
                    }
                }
                
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
