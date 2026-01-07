import SwiftUI

struct MascotReactionView: View {

    let xp: Int

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 48))

            Text(message)
                .font(.headline)

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var emoji: String {
        switch xp {
        case 0..<500: return "🙂"
        case 500..<2000: return "😄"
        case 2000..<5000: return "🤩"
        default: return "🔥"
        }
    }

    private var message: String {
        switch xp {
        case 0..<500: return "Nice start! Keep going!"
        case 500..<2000: return "You’re on fire!"
        case 2000..<5000: return "Incredible progress!"
        default: return "You’re unstoppable 🚀"
        }
    }
}
