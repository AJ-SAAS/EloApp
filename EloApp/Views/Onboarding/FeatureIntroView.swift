// Views/Onboarding/FeatureIntroView.swift

import SwiftUI

struct FeatureIntroView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack {
            Spacer()  // Pushes everything to bottom third
            
            // Optional illustration placeholder (you can replace with real images later)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 280)
                .padding(.horizontal)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 80))
                        .foregroundColor(.gray.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.system(size: 48, weight: .bold))  // Same size as Welcome title
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal)
            
            Spacer().frame(height: 80)  // Space before "Continue" button
        }
        .padding()
    }
}
