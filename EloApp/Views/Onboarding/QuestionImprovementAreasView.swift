// Views/Onboarding/QuestionImprovementAreasView.swift

import SwiftUI

struct QuestionImprovementAreasView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    let areas = [
        "Career & Job",
        "Family & Friends",
        "Communicating with Parents",
        "Travels",
        "Brain Training",
        "Education"
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("In which areas would you like to improve your English?")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(areas, id: \.self) { area in
                    Button {
                        if vm.improvementAreas.contains(area) {
                            vm.improvementAreas.remove(area)
                        } else {
                            vm.improvementAreas.insert(area)
                        }
                    } label: {
                        Text(area)
                            .font(.title2.bold())  // Larger, bolder text for readability
                            .foregroundColor(vm.improvementAreas.contains(area) ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(vm.improvementAreas.contains(area) ? Color.blue : Color.gray.opacity(0.1))
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
