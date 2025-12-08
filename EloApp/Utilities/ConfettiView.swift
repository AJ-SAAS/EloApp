import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<80) { _ in
                Circle()
                    .fill([Color.red, .blue, .green, .yellow, .purple, .orange].randomElement()!)
                    .frame(width: 20, height: 20)
                    .offset(x: .random(in: -proxy.size.width...proxy.size.width),
                            y: animate ? proxy.size.height + 50 : -50)
                    .rotationEffect(.degrees(.random(in: 0...360)))
                    .animation(
                        Animation.linear(duration: .random(in: 2...4))
                            .repeatCount(1),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}
