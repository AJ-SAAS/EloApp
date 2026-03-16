import SwiftUI

struct PreparingPlanView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var progress: CGFloat = 0.0
    @State private var currentBulletIndex: Int = -1
    @State private var animatePulse: Bool = false

    let bullets = [
        "Creating diverse topics",
        "Preparing interactive dialogues",
        "Optimizing your learning path",
        "Finalizing your plan"
    ]

    private let gradientColors = [Color.eloTeal, Color.eloTealLight]

    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 40)

            ZStack {
                Circle()
                    .stroke(Color.eloTeal.opacity(0.1), lineWidth: 12)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: gradientColors,
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 180, height: 180)
                    .animation(.easeInOut(duration: 0.8), value: progress)

                ZStack {
                    Circle()
                        .fill(Color.eloTeal.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .scaleEffect(animatePulse ? 1.15 : 1)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animatePulse)

                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.eloTeal)
                        .scaleEffect(animatePulse ? 1.08 : 1)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animatePulse)
                }
            }
            .onAppear { animatePulse = true }

            Text("Personalizing your learning plan…")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 24) {
                ForEach(Array(bullets.enumerated()), id: \.offset) { index, text in
                    HStack(spacing: 12) {
                        Image(systemName: index <= currentBulletIndex ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(index <= currentBulletIndex ? .eloTeal : Color.eloTeal.opacity(0.3))
                            .font(.system(size: 22))
                            .scaleEffect(index == currentBulletIndex ? 1.2 : 1)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentBulletIndex)

                        Text(text)
                            .foregroundColor(index <= currentBulletIndex ? .primary : .secondary)
                            .font(.system(size: 18, weight: .semibold))
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(index <= currentBulletIndex ? 1 : 0.4)
                            .offset(x: index <= currentBulletIndex ? 0 : -20)
                            .animation(
                                .interpolatingSpring(stiffness: 200, damping: 18)
                                    .delay(Double(index) * 0.1),
                                value: currentBulletIndex
                            )
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.white, Color.eloTeal.opacity(0.04)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear { runProgressSequence() }
    }

    private func runProgressSequence() {
        let delays: [Double] = [0.5, 0.5, 1.0, 1.0]
        let holdTime: Double = 0.5
        let progresses: [CGFloat] = [0.17, 0.43, 0.67, 0.81]

        func animateBullet(_ index: Int) {
            guard index < bullets.count else {
                withAnimation(.easeInOut(duration: 0.5)) { progress = 1.0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    vm.nextPage()
                }
                return
            }

            withAnimation(.easeInOut(duration: delays[index])) { progress = progresses[index] }

            DispatchQueue.main.asyncAfter(deadline: .now() + delays[index]) {
                withAnimation { currentBulletIndex = index }
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + holdTime) {
                    animateBullet(index + 1)
                }
            }
        }

        animateBullet(0)
    }
}
