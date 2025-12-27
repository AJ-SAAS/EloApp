// Views/Onboarding/SplashView.swift

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                Image("elo_logo") // Replace with your actual logo asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .padding()
                
                Text("Elo")
                    .font(.largeTitle.bold())
                    .foregroundColor(.blue)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            OnboardingContainerView()
        }
    }
}
