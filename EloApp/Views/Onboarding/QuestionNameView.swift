import SwiftUI

struct QuestionNameView: View {
    @ObservedObject var vm: OnboardingViewModel
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("What's your name?")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Elo will call you by this name.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Enter your name", text: $vm.userName)
                .font(.system(size: 28, weight: .medium))
                .padding(24)
                .frame(height: 80)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .focused($isNameFocused)
                .submitLabel(.done)
                .onSubmit {
                    isNameFocused = false
                    if !vm.userName.trimmingCharacters(in: .whitespaces).isEmpty {
                        vm.nextPage()
                    }
                }
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            isNameFocused = false
        }
        .onDisappear {
            // 🔑 THIS is what actually fixes the issue
            isNameFocused = false
        }
    }
}
