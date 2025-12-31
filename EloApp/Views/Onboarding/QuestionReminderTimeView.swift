import SwiftUI

struct QuestionReminderTimeView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 40) {
                Spacer().frame(height: 40)
                
                Text("Pick a time of the day to start your practice every day")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                DatePicker(
                    "Reminder Time",
                    selection: $vm.reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                
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
