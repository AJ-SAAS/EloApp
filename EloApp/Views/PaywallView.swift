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

    let navyBlue = Color(red: 0.0, green: 0.3, blue: 0.5)
    let accentBlue = Color(red: 0.1, green: 0.45, blue: 0.95)

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
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
    }

    // MARK: - Components

    private var closeButton: some View {
        HStack {
            Spacer()
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
        }
    }

    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("Elo Premium")
                .font(.title3.bold())
                .foregroundColor(accentBlue)

            Text("Get Unlimited Access")
                .font(.system(.largeTitle, design: .serif).weight(.bold))
                .foregroundColor(navyBlue)
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Text("In 28 days, your English will help you respond to any unexpected situation on a trip.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 6)
    }

    // MARK: - Centered Features (text now larger)
    private var featuresSection: some View {
        VStack(spacing: 20) {
            FeatureBulletCentered(text: "Unlimited interactive practice", navyBlue: navyBlue)
            FeatureBulletCentered(text: "Personalized study plan", navyBlue: navyBlue)
            FeatureBulletCentered(text: "Real-time AI feedback", navyBlue: navyBlue)
            FeatureBulletCentered(text: "Control & track your progress", navyBlue: navyBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var offersSection: some View {
        VStack(spacing: 16) {
            if let packages = purchaseVM.offerings?.current?.availablePackages {
                ForEach(packages, id: \.identifier) { package in
                    let type: OfferType = package.identifier.contains("lifetime") ? .lifetime : .weekly
                    OfferCard(
                        title: package.storeProduct.localizedTitle,
                        price: package.storeProduct.localizedPriceString,
                        offerType: type,
                        isSelected: selectedOffer == type,
                        onTap: { withAnimation { selectedOffer = type } },
                        accentColor: accentBlue,
                        textColor: navyBlue
                    )
                }
            } else {
                OfferCard(
                    title: "Lifetime Access",
                    price: "$17.99 one-time payment",
                    offerType: .lifetime,
                    isSelected: selectedOffer == .lifetime,
                    onTap: { withAnimation { selectedOffer = .lifetime } },
                    accentColor: accentBlue,
                    textColor: navyBlue
                )
                OfferCard(
                    title: "Weekly Access",
                    price: "$4.99 / week",
                    offerType: .weekly,
                    isSelected: selectedOffer == .weekly,
                    onTap: { withAnimation { selectedOffer = .weekly } },
                    accentColor: accentBlue,
                    textColor: navyBlue
                )
            }
            FreeTrialCard(isEnabled: $isFreeTrialEnabled, textColor: navyBlue, toggleTint: accentBlue)
        }
    }

    private var dueSection: some View {
        FreeTrialDueView(navyBlue: navyBlue)
            .padding(.top, -10)
    }

    private var ctaButton: some View {
        Button(action: {
            Task { await purchaseSelectedOffer() }
        }) {
            Text(selectedOffer == .weekly && isFreeTrialEnabled ? "Try Free Today →" : "Unlock Full Access")
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(accentBlue)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                .scaleEffect(isProcessingPurchase ? 0.95 : 1.0)
        }
        .disabled(isProcessingPurchase)
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
        HStack {
            Button("Terms of Use") {}
                .font(.subheadline)
                .foregroundColor(accentBlue)

            Spacer()

            Button("Restore Subscriptions") {
                Task { await restorePurchases() }
            }
            .font(.subheadline)
            .foregroundColor(accentBlue)
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
            ? packages.first { $0.identifier.contains("lifetime") }
            : packages.first { $0.identifier.contains("weekly") }

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
    let navyBlue: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(navyBlue)

            Text(text)
                .font(.headline.bold())  // ← Increased size (was .subheadline.bold())
                .foregroundColor(.primary)
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
                    Text(price)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
                    Text(trialEndDateString())
                        .font(.headline)
                        .foregroundColor(navyBlue)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("$12.95")
                            .font(.subheadline.bold())
                            .strikethrough()
                            .foregroundColor(.red)
                        Text("$4.99")
                            .font(.headline)
                            .foregroundColor(navyBlue)
                    }
                }
            }
        }
    }

    func trialEndDateString() -> String {
        let calendar = Calendar.current
        let today = Date()
        guard let trialEndDate = calendar.date(byAdding: .day, value: 6, to: today) else { return "Due in 7 days" }
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM d, yyyy"
        let dateStr = formatter.string(from: trialEndDate)
        return "Due \(dateStr)"
    }
}
