// Views/Onboarding/ScratchWinView.swift

import SwiftUI

struct ScratchWinView: View {
    @ObservedObject var vm: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Scratch & Win")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Text("Pick a card to get your special offer!")
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 30) {
                ScratchCard(index: 0, discount: "90% off", isWinner: true, vm: vm)
                ScratchCard(index: 1, discount: "35% off", isWinner: false, vm: vm)
                ScratchCard(index: 2, discount: "0% off", isWinner: false, vm: vm)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.red.ignoresSafeArea())
    }
}

struct ScratchCard: View {
    let index: Int
    let discount: String
    let isWinner: Bool
    @ObservedObject var vm: OnboardingViewModel
    @State private var revealed = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.8))
                .frame(width: 110, height: 160)
                .overlay(
                    Text(revealed ? "" : "Scratch")
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            if revealed {
                VStack {
                    Text(discount)
                        .font(.title.bold())
                        .foregroundColor(isWinner ? .yellow : .white)
                    
                    if isWinner {
                        Text("WINNER!")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                revealed = true
                vm.scratchedCards.insert(index)
            }
            
            // Reveal all cards and go to claim after short delay
            if index == 0 { // User picked the winner
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    vm.scratchedCards.insert(1)
                    vm.scratchedCards.insert(2)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    vm.currentPage = .claimReward
                }
            }
        }
    }
}
