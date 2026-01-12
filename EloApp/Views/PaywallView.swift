import SwiftUI
import RevenueCat
import FirebaseAuth
import Combine

struct PaywallView: View {
    let vm: OnboardingViewModel
    var showAuthInline: Bool = false

    @StateObject private var purchaseVM = PurchaseViewModel()
    @State private var selectedOffer: OfferType = .weekly
    @State private var isFreeTrialEnabled = true
    @State private var isProcessingPurchase = false
    @State private var purchaseError: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                closeButton
                titleSection
                featuresSection
                offersSection
                dueSection
                ctaButton
                errorMessage
                inlineAuth
                bottomButtons
            }
            .padding(.horizontal)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear { purchaseVM.fetchOfferings() }
        .onChange(of: selectedOffer) { newValue in
            isFreeTrialEnabled = (newValue == .weekly)
        }
        .onChange(of: isFreeTrialEnabled) { newValue in
            // When toggle changes, update the selected offer
            withAnimation {
                selectedOffer = newValue ? .weekly : .lifetime
            }
        }
    }

    // MARK: - Components

    private var closeButton: some View {
        HStack {
            Button {
                if showAuthInline {
                    ProgressTracker.shared.markOnboardingCompleted()
                } else {
                    vm.skipPaywall()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }
            
            Spacer()
            
            Button("Restore") {
                Task { await restorePurchases() }
            }
            .font(.subheadline)
            .foregroundColor(Color(red: 0.078, green: 0.722, blue: 0.651)) // #14B8A6 Teal
        }
        .padding(.top, 8)
    }

    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("Elo Premium")
                .font(.title3.bold())
                .foregroundColor(Color(red: 0.976, green: 0.451, blue: 0.086)) // #F97316 Coral

            Text("Get Unlimited Access")
                .font(.system(.largeTitle, design: .default).weight(.bold))
                .foregroundColor(Color(red: 0.192, green: 0.18, blue: 0.506)) // #312E81 Deep Indigo
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Text("In 28 days, your English will help you respond to any unexpected situation on a trip.")
                .font(.subheadline)
                .foregroundColor(Color(red: 0.471, green: 0.443, blue: 0.424)) // #78716C Warm Gray
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Centered Features (text now larger)
    private var featuresSection: some View {
        VStack(spacing: 8) {
            FeatureBulletCentered(text: "Unlimited interactive practice", iconColor: Color(red: 0.078, green: 0.722, blue: 0.651)) // #14B8A6 Teal
            FeatureBulletCentered(text: "Personalized study plan", iconColor: Color(red: 0.078, green: 0.722, blue: 0.651))
            FeatureBulletCentered(text: "Real-time AI feedback", iconColor: Color(red: 0.078, green: 0.722, blue: 0.651))
            FeatureBulletCentered(text: "Control & track your progress", iconColor: Color(red: 0.078, green: 0.722, blue: 0.651))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private var offersSection: some View {
        VStack(spacing: 10) {
            if let packages = purchaseVM.offerings?.current?.availablePackages {
                ForEach(packages, id: \.identifier) { package in
                    let type: OfferType = package.storeProduct.productIdentifier.contains("lifetime") ? .lifetime : .weekly
                    let subtitle = type == .lifetime ? "one-time payment" : "per week"
                    OfferCard(
                        title: package.storeProduct.localizedTitle,
                        price: package.storeProduct.localizedPriceString,
                        subtitle: subtitle,
                        offerType: type,
                        isSelected: selectedOffer == type,
                        onTap: { withAnimation { selectedOffer = type } },
                        accentColor: Color(red: 0.078, green: 0.722, blue: 0.651), // #14B8A6 Teal
                        textColor: Color(red: 0.161, green: 0.145, blue: 0.141) // #292524 Charcoal
                    )
                }
            } else {
                OfferCard(
                    title: "Lifetime Access",
                    price: "$17.99",
                    subtitle: "one-time payment",
                    offerType: .lifetime,
                    isSelected: selectedOffer == .lifetime,
                    onTap: { withAnimation { selectedOffer = .lifetime } },
                    accentColor: Color(red: 0.078, green: 0.722, blue: 0.651), // #14B8A6 Teal
                    textColor: Color(red: 0.161, green: 0.145, blue: 0.141) // #292524 Charcoal
                )
                OfferCard(
                    title: "Weekly Access",
                    price: "$4.99",
                    subtitle: "per week",
                    offerType: .weekly,
                    isSelected: selectedOffer == .weekly,
                    onTap: { withAnimation { selectedOffer = .weekly } },
                    accentColor: Color(red: 0.078, green: 0.722, blue: 0.651), // #14B8A6 Teal
                    textColor: Color(red: 0.161, green: 0.145, blue: 0.141) // #292524 Charcoal
                )
            }
            
            FreeTrialCard(
                isEnabled: $isFreeTrialEnabled,
                textColor: Color(red: 0.161, green: 0.145, blue: 0.141), // #292524 Charcoal
                toggleTint: Color(red: 0.078, green: 0.722, blue: 0.651) // #14B8A6 Teal
            )
        }
    }

    private var dueSection: some View {
        FreeTrialDueView(
            primaryColor: Color(red: 0.192, green: 0.18, blue: 0.506), // #312E81 Deep Indigo
            accentColor: Color(red: 0.976, green: 0.451, blue: 0.086), // #F97316 Coral
            selectedOffer: selectedOffer,
            isFreeTrialEnabled: isFreeTrialEnabled
        )
        .padding(.top, -10)
    }

    private var ctaButton: some View {
        Button(action: {
            Task { await purchaseSelectedOffer() }
        }) {
            Text(buttonText)
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.078, green: 0.722, blue: 0.651)) // #14B8A6 Teal
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                .scaleEffect(isProcessingPurchase ? 0.95 : 1.0)
        }
        .disabled(isProcessingPurchase)
    }
    
    private var buttonText: String {
        if selectedOffer == .lifetime {
            return "Start Now"
        } else if isFreeTrialEnabled {
            return "Try Free Today →"
        } else {
            return "Unlock Full Access"
        }
    }

    @ViewBuilder
    private var errorMessage: some View {
        if let error = purchaseError {
            Text(error)
                .foregroundColor(.red)
                .font(.subheadline)
                .padding(.top, 4)
        }
    }

    @ViewBuilder
    private var inlineAuth: some View {
        if showAuthInline && purchaseVM.hasPremiumAccess() {
            Divider().padding(.vertical, 20)
            AuthView()
        }
    }

    private var bottomButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.078, green: 0.722, blue: 0.651)) // #14B8A6 Teal
                
                Link("Privacy Policy", destination: URL(string: "https://www.tryeloenglish.xyz/privacy")!)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.078, green: 0.722, blue: 0.651)) // #14B8A6 Teal
            }
        }
        .padding(.bottom)
    }

    // MARK: - Purchase Functions

    private func purchaseSelectedOffer() async {
        guard let packages = purchaseVM.offerings?.current?.availablePackages else {
            purchaseError = "No packages available."
            return
        }
        isProcessingPurchase = true
        defer { isProcessingPurchase = false }
        purchaseError = nil

        let package = selectedOffer == .lifetime
            ? packages.first { $0.storeProduct.productIdentifier.contains("lifetime") }
            : packages.first { $0.storeProduct.productIdentifier.contains("weekly") }

        if let package {
            let success = await purchaseVM.purchase(package: package)
            if success {
                ProgressTracker.shared.hasPremiumAccess = true
                vm.skipPaywall()
            } else { purchaseError = "Purchase failed. Try again." }
        } else {
            purchaseError = "Selected package not found."
        }
    }

    private func restorePurchases() async {
        isProcessingPurchase = true
        defer { isProcessingPurchase = false }
        purchaseError = nil
        await purchaseVM.restorePurchases()
        if purchaseVM.hasPremiumAccess() {
            ProgressTracker.shared.hasPremiumAccess = true
            vm.skipPaywall()
        } else {
            purchaseError = "No active purchases found."
        }
    }
}

// MARK: - Offer Type
enum OfferType {
    case lifetime
    case weekly
}

// MARK: - Centered Feature Bullet (text now larger: .headline)
struct FeatureBulletCentered: View {
    let text: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(iconColor)

            Text(text)
                .font(.headline.bold())
                .foregroundColor(Color(red: 0.161, green: 0.145, blue: 0.141))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 340, alignment: .center)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Offer Card
struct OfferCard: View {
    let title: String
    let price: String
    let subtitle: String
    let offerType: OfferType
    let isSelected: Bool
    let onTap: () -> Void
    let accentColor: Color
    let textColor: Color

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundColor(textColor)
                    HStack(spacing: 4) {
                        Text(price)
                            .font(.subheadline.bold())
                            .foregroundColor(textColor)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(isSelected ? accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(accentColor)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? accentColor.opacity(0.08) : Color.gray.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? accentColor : Color.gray.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: isSelected ? accentColor.opacity(0.15) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Free Trial Card
struct FreeTrialCard: View {
    @Binding var isEnabled: Bool
    let textColor: Color
    let toggleTint: Color

    var body: some View {
        HStack {
            Text("Free Trial Enabled")
                .font(.subheadline.bold())
                .foregroundColor(textColor)
            Spacer()
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(toggleTint)
        }
        .padding(12)
        .background(Color.gray.opacity(0.12))
        .cornerRadius(12)
    }
}

// MARK: - Free Trial Due View
struct FreeTrialDueView: View {
    let primaryColor: Color
    let accentColor: Color
    let selectedOffer: OfferType
    let isFreeTrialEnabled: Bool

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
                // First Row
                HStack {
                    Text("Due today")
                        .font(.subheadline.bold())
                        .foregroundColor(primaryColor)
                    Spacer()
                    HStack(spacing: 4) {
                        if selectedOffer == .lifetime {
                            Text("$17.99")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                        } else {
                            Text("7 days free")
                                .font(.subheadline.bold())
                                .foregroundColor(.green)
                            Text("$0.00")
                                .font(.subheadline)
                                .foregroundColor(primaryColor)
                        }
                    }
                }

                // Second Row
                HStack {
                    Text(secondRowLeftText())
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    Spacer()
                    HStack(spacing: 4) {
                        if selectedOffer == .lifetime {
                            Text("Save 70%")
                                .font(.headline)
                                .foregroundColor(.green)
                        } else {
                            Text("$12.95")
                                .font(.subheadline.bold())
                                .strikethrough()
                                .foregroundColor(accentColor)
                            Text("$4.99")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                        }
                    }
                }
            }
        }
    }

    func secondRowLeftText() -> String {
        if selectedOffer == .lifetime {
            return "No payment for weeks"
        } else {
            let calendar = Calendar.current
            let today = Date()
            guard let trialEndDate = calendar.date(byAdding: .day, value: 6, to: today) else {
                return "Due in 7 days"
            }
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "MMMM d, yyyy"
            let dateStr = formatter.string(from: trialEndDate)
            return "Due \(dateStr)"
        }
    }
}
