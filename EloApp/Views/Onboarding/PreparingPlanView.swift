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
    
    // MARK: Colors
    private let gradientColors = [Color.purple, Color.pink]

    var body: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 40)
            
            // MARK: Circular Progress with Pulsing Icon
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
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
                
                Image(systemName: "book.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                    .scaleEffect(animatePulse ? 1.15 : 1)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animatePulse)
            }
            .onAppear { animatePulse = true }
            
            // MARK: Title - Apple-grade serif font
            Text("Personalizing your learning plan…")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.primary)
            
            // MARK: Animated Bullet List
            VStack(alignment: .leading, spacing: 24) {
                ForEach(Array(bullets.enumerated()), id: \.offset) { index, text in
                    HStack(spacing: 12) {
                        Image(systemName: index <= currentBulletIndex ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(index <= currentBulletIndex ? .green : .gray)
                            .scaleEffect(index == currentBulletIndex ? 1.2 : 1)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentBulletIndex)
                        
                        Text(text)
                            .foregroundColor(index <= currentBulletIndex ? .primary : .secondary)
                            .font(.system(size: 20, weight: .semibold)) // Updated to Apple-grade bullet font
                            .opacity(index <= currentBulletIndex ? 1 : 0)
                            .offset(x: index <= currentBulletIndex ? 0 : -20, y: 0)
                            .scaleEffect(index <= currentBulletIndex ? 1 : 0.95)
                            .animation(
                                .interpolatingSpring(stiffness: 200, damping: 18)
                                    .delay(Double(index) * 0.1),
                                value: currentBulletIndex
                            )
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.white, Color(red: 250/255, green: 245/255, blue: 255/255)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear { runProgressSequence() }
    }
    
    // MARK: Progress Sequence with pauses per bullet
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
