// Views/Onboarding/PreparingPlanView.swift

import SwiftUI

struct PreparingPlanView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var progress: CGFloat = 0.0
    
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
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                    .animation(.linear(duration: 4.0), value: progress)
                
                // Replace with your actual Elo logo asset
                Image(systemName: "book.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
            }
            
            Text("Personalizing your learning plan...")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(bullets.enumerated()), id: \.offset) { index, text in
                    HStack(spacing: 12) {
                        Image(systemName: progress >= CGFloat(index + 1) / CGFloat(bullets.count) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.green)
                        
                        Text(text)
                            .foregroundColor(progress >= CGFloat(index) / CGFloat(bullets.count) ? .primary : .secondary)
                    }
                    .font(.title3)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            withAnimation {
                progress = 1.0
            }
            // Auto-advance after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                vm.nextPage()
            }
        }
    }
}
