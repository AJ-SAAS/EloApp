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
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(level)
                                        .font(.system(size: 20, weight: .semibold))
                                    
                                    Text(description)
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(vm.englishLevel == level ? Color.purple : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(vm.englishLevel == level ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Back button
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
