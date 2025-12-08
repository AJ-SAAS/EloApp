import SwiftUI

struct CompletionView: View {
    let streak: Int
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Text("WORD MASTERED")
                .font(.system(size: 60, weight: .black, design: .rounded))
                .foregroundColor(.yellow)
                .scaleEffect(1.1)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: 1)
            
            Text("Streak: \(streak)")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.orange)
            
            Text("+100 XP")
                .font(.title)
                .foregroundColor(.white)
            
            Button("Continue →") {
                onContinue()
            }
            .font(.title2)
            .bold()
            .foregroundColor(.black)
            .padding(.horizontal, 60)
            .padding(.vertical, 20)
            .background(.yellow)
            .cornerRadius(20)
            .padding(.top, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
