import SwiftUI

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                Spacer()
                Text(value).bold()
            }

            SwiftUI.ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
