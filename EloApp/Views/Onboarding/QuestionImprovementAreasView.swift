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
        ZStack(alignment: .topLeading) {
            VStack(spacing: 30) {
                Spacer().frame(height: 60)
                
                Text("In which areas would you like to improve your English?")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                
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
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(vm.improvementAreas.contains(area) ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(vm.improvementAreas.contains(area) ? Color.purple : Color.gray.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Button {
                vm.previousPage()
            } label: {
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
