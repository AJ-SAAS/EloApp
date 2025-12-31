import SwiftUI

struct PaywallView: View {
    let vm: OnboardingViewModel
    
    @State private var selectedOffer: OfferType = .lifetime
    @State private var isFreeTrialEnabled = true
    
    let navyBlue = Color(red: 0.0, green: 0.3, blue: 0.5)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Top Close Button
                HStack {
                    Spacer()
                    Button(action: { vm.skipPaywall() }) {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                    }
                }
                .padding(.horizontal)
                
                // Title
                VStack(spacing: 6) {
                    Text("New Year\nNew Language!")
                        .font(.largeTitle.bold())
                        .foregroundColor(navyBlue)
                        .multilineTextAlignment(.center)
                    
                    Text("In 28 days, your English will help you respond to any unexpected situation on a trip.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 6)
                
                // Features - Centered bullets with bigger checkmarks
                VStack(spacing: 14) {
                    FeatureBulletCentered(text: "Unlimited interactive practice", navyBlue: navyBlue)
                    FeatureBulletCentered(text: "Personalized study plan", navyBlue: navyBlue)
                    FeatureBulletCentered(text: "Real-time AI feedback", navyBlue: navyBlue)
                    FeatureBulletCentered(text: "Control & track your progress", navyBlue: navyBlue)
                }
                .padding(.horizontal)
                
                // Offer Cards
                VStack(spacing: 14) {
                    OfferCard(
                        title: "Lifetime Access",
                        price: "$17.99 one-time payment",
                        offerType: .lifetime,
                        isSelected: selectedOffer == .lifetime,
                        onTap: { selectedOffer = .lifetime },
                        navyBlue: navyBlue
                    )
                    
                    OfferCard(
                        title: "Weekly Access",
                        price: "$6.49 / week",
                        offerType: .weekly,
                        isSelected: selectedOffer == .weekly,
                        onTap: { selectedOffer = .weekly },
                        navyBlue: navyBlue
                    )
                    
                    FreeTrialCard(isEnabled: $isFreeTrialEnabled, navyBlue: navyBlue)
                }
                .padding(.horizontal)
                
                // Free trial due section
                FreeTrialDueView(navyBlue: navyBlue)
                    .padding(.horizontal)
                    .padding(.top, -10)
                
                // Try Free Button - gradient modern look
                Button(action: {
                    // Trigger subscription purchase
                }) {
                    Text("Try Free")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                
                // Bottom buttons
                HStack(spacing: 16) {
                    Button("Terms of Use") {}
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Spacer()
                    Button("Restore Subscriptions") {}
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Offer Type
enum OfferType {
    case lifetime
    case weekly
}

// MARK: - Feature Bullet (modern centered)
struct FeatureBulletCentered: View {
    let text: String
    let navyBlue: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(navyBlue)
            Text(text)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Offer Card (modernized)
struct OfferCard: View {
    let title: String
    let price: String
    let offerType: OfferType
    let isSelected: Bool
    let onTap: () -> Void
    let navyBlue: Color
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundColor(navyBlue)
                    Text(price)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? navyBlue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(navyBlue)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? navyBlue.opacity(0.08) : Color.gray.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? navyBlue : Color.gray.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: isSelected ? navyBlue.opacity(0.15) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Free Trial Card (modern)
struct FreeTrialCard: View {
    @Binding var isEnabled: Bool
    let navyBlue: Color
    
    var body: some View {
        HStack {
            Text("Free Trial Enabled")
                .font(.subheadline.bold())
                .foregroundColor(navyBlue)
            Spacer()
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(navyBlue)
        }
        .padding(12)
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
    }
}

// MARK: - Free Trial Due View
struct FreeTrialDueView: View {
    let navyBlue: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 8, height: 8)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 2, height: 16)
                
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 8, height: 8)
            }
            .padding(.top, 4)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Due today")
                        .font(.subheadline.bold())
                        .foregroundColor(navyBlue)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("7 days free")
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                        Text("$0.00")
                            .font(.subheadline)
                            .foregroundColor(navyBlue)
                    }
                }
                
                HStack {
                    Text("Due \(trialEndDateString())")
                        .font(.subheadline.bold())
                        .foregroundColor(navyBlue)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("$12.95")
                            .font(.subheadline.bold())
                            .strikethrough()
                            .foregroundColor(.red)
                        Text("$6.49")
                            .font(.subheadline.bold())
                            .foregroundColor(navyBlue)
                    }
                }
            }
        }
    }
    
    func trialEndDateString() -> String {
        let calendar = Calendar.current
        let today = Date()
        guard let trialEndDate = calendar.date(byAdding: .day, value: 6, to: today) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: trialEndDate)
    }
}
