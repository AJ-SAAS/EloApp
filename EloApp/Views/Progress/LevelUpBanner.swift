import SwiftUI

struct LevelUpBanner: View {

    let level: Int

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 8) {
                Text("LEVEL UP 🎉")
                    .font(.headline)
                Text("Level \(level)")
                    .font(.largeTitle.bold())
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.yellow.opacity(0.95))
            .cornerRadius(20)
            .padding()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
