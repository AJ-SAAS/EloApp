// Views/Onboarding/QuestionEnglishLevelView.swift

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
        VStack(spacing: 30) {
            Text("What is your level of English?")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(levels, id: \.self) { level in
                    Button(action: {
                        vm.englishLevel = level
                        vm.nextPage()
                    }) {
                        Text(level)
                            .font(.title2.bold())  // Larger, bolder text for better readability
                            .foregroundColor(vm.englishLevel == level ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(vm.englishLevel == level ? Color.blue : Color.gray.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
