import SwiftUI

struct QuestionNameView: View {
    @ObservedObject var vm: OnboardingViewModel
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer().frame(height: 40)
            
            Text("What should we call you?")
                .font(.system(size: 36, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Elo will call you by this name.")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Enter your name", text: $vm.userName)
                .font(.system(size: 28, weight: .medium))
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(height: 80)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .focused($isNameFocused)
                .submitLabel(.done)
                .onSubmit { isNameFocused = false }
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture { isNameFocused = false }
        .onDisappear { isNameFocused = false }
    }
}
