import SwiftUI

struct PreparingPlanView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var progress: CGFloat = 0.0
    @State private var currentBulletIndex: Int = -1

    let bullets = [
        "Creating diverse topics",
        "Preparing interactive dialogues",
        "Optimizing your learning path",
        "Finalizing your plan"
    ]

    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                    .animation(.linear, value: progress)

                Image(systemName: "book.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
            }

            Text("Personalizing your learning plan...")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(bullets.enumerated()), id: \.offset) { index, text in
                    HStack(spacing: 12) {
                        Image(systemName: index <= currentBulletIndex ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(index <= currentBulletIndex ? .green : .gray)
                        Text(text)
                            .foregroundColor(index <= currentBulletIndex ? .primary : .secondary)
                    }
                    .font(.title3)
                    .opacity(index <= currentBulletIndex ? 1 : 0.5)
                    .animation(.easeIn(duration: 0.3), value: currentBulletIndex)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            runProgressSequence()
        }
    }

    private func runProgressSequence() {
        let delays: [Double] = [0.5, 0.5, 1.0, 1.0]
        let progresses: [CGFloat] = [0.17, 0.43, 0.67, 0.81]

        func animateBullet(_ index: Int) {
            guard index < bullets.count else {
                // Complete progress to 100% after last bullet
                withAnimation(.linear(duration: 0.5)) {
                    progress = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    vm.nextPage()
                }
                return
            }

            withAnimation(.linear(duration: 0.5)) {
                progress = progresses[index]
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + delays[index]) {
                withAnimation {
                    currentBulletIndex = index
                }
                animateBullet(index + 1)
            }
        }

        animateBullet(0)
    }
}
