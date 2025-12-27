import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .bold))  // ← ~2pt bigger than .headline + bold
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)     // ← More vertical inner padding (top & bottom)
            .padding(.horizontal, 20)   // Slightly more horizontal too for balance
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .padding(.horizontal)       // Outer horizontal padding (keeps button from edge)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)  // Optional: subtle press animation
    }
}
