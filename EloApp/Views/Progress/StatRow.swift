import SwiftUI

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let progress: Double
    let color: Color
    @Binding var animate: Bool // Controlled by parent

    @State private var animatedProgress = 0.0
    @State private var glow = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title + Icon + Value
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.headline)
                Text(title)
                    .font(.headline)
                Spacer()
                Text(value)
                    .bold()
            }

            // Animated Progress Bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.2))
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: CGFloat(animatedProgress) * UIScreen.main.bounds.width * 0.85, height: 8)
                    .shadow(color: glow ? color.opacity(0.4) : .clear, radius: 6, x: 0, y: 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.5), value: animatedProgress)
            }
        }
        .padding()
        .background(color.opacity(0.15))
        .cornerRadius(16)
        .onChange(of: animate) { _ in animateBar() }
        .onAppear { animateBar() }
    }

    private func animateBar() {
        withAnimation {
            animatedProgress = animate ? progress : 0
        }

        // Trigger glow and haptic if filled
        if progress >= 1.0 {
            glow = true
            Haptics.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                glow = false
            }
        }
    }
}
