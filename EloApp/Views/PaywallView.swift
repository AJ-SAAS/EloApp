import SwiftUI
import RevenueCat
import FirebaseAuth
import Combine

struct PaywallView: View {
    let vm: OnboardingViewModel
    var showAuthInline: Bool = false

    @StateObject private var purchaseVM = PurchaseViewModel()
    @State private var selectedOffer: OfferType = .weekly
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
            .padding(.horizontal, 20)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear { purchaseVM.fetchOfferings() }
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
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color(.systemGray5)))
            }

            Spacer()

            Button("Restore") {
                Task { await restorePurchases() }
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.eloTeal)
        }
        .padding(.top, 8)
    }

    private var titleSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 5) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.eloOrange)
                Text("ELO PREMIUM")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.eloOrange)
                    .kerning(0.5)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.eloOrangeLight))
            .overlay(Capsule().stroke(Color.eloOrange.opacity(0.25), lineWidth: 0.5))

            Text("Master English\nword by word")
                .font(.system(size: 28, weight: .semibold, design: .default))
                .foregroundColor(.eloText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("Hold your first confident English sentence in just 7 days, using our science-backed method.")
                .font(.subheadline)
                .foregroundColor(.eloSubtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
    }

    private var featuresSection: some View {
        VStack(spacing: 12) {
            FeatureBulletCentered(text: "Daily AI-guided practice sessions", iconColor: .eloTeal)
            FeatureBulletCentered(text: "Speak, record, and recall every word", iconColor: .eloTeal)
            FeatureBulletCentered(text: "Real-time feedback and progress tracking", iconColor: .eloTeal)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 0.973, blue: 0.851))
        )
    }

    private var offersSection: some View {
        VStack(spacing: 10) {
            if let packages = purchaseVM.offerings?.current?.availablePackages {
                ForEach(packages, id: \.identifier) { package in
                    let type: OfferType = package.storeProduct.productIdentifier.contains("yearly") ? .yearly : .weekly
                    let subtitle = type == .yearly ? "per year" : "per week"
                    
                    OfferCard(
                        title: package.storeProduct.localizedTitle,
                        price: package.storeProduct.localizedPriceString,
                        subtitle: subtitle,
                        offerType: type,
                        isSelected: selectedOffer == type,
                        onTap: { withAnimation(.easeInOut(duration: 0.18)) { selectedOffer = type } },
                        accentColor: .eloTeal,
                        textColor: .eloText
                    )
                }
            } else {
                // fallback hardcoded offers
                OfferCard(
                    title: "Weekly Premium",
                    price: "$0.99",
                    subtitle: "per week",
                    offerType: .weekly,
                    isSelected: selectedOffer == .weekly,
                    onTap: { withAnimation(.easeInOut(duration: 0.18)) { selectedOffer = .weekly } },
                    accentColor: .eloTeal,
                    textColor: .eloText
                )
                OfferCard(
                    title: "Yearly Premium",
                    price: "$39.99",
                    subtitle: "per year",
                    offerType: .yearly,
                    isSelected: selectedOffer == .yearly,
                    onTap: { withAnimation(.easeInOut(duration: 0.18)) { selectedOffer = .yearly } },
                    accentColor: .eloTeal,
                    textColor: .eloText
                )
            }
        }
    }

    private var dueSection: some View {
        FreeTrialDueView(
            primaryColor: .eloTeal,
            accentColor: .eloOrange,
            selectedOffer: selectedOffer
        )
    }

    private var ctaButton: some View {
        VStack(spacing: 6) {
            Button(action: {
                Task { await purchaseSelectedOffer() }
            }) {
                Group {
                    if isProcessingPurchase {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(selectedOffer == .weekly ? "Start learning for free →" : "Get yearly access →")
                            .font(.headline)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.eloTeal))
                .scaleEffect(isProcessingPurchase ? 0.97 : 1.0)
            }
            .disabled(isProcessingPurchase)
            .animation(.easeInOut(duration: 0.15), value: isProcessingPurchase)

            Text("No commitment · cancel anytime")
                .font(.caption)
                .foregroundColor(Color(.systemGray2))
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
        HStack(spacing: 20) {
            Link("Terms of use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                .font(.caption)
                .foregroundColor(Color(.systemGray2))
            Link("Privacy policy", destination: URL(string: "https://www.tryeloenglish.xyz/privacy")!)
                .font(.caption)
                .foregroundColor(Color(.systemGray2))
        }
        .padding(.bottom, 8)
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

        let package = selectedOffer == .yearly
            ? packages.first { $0.storeProduct.productIdentifier.contains("yearly") }
            : packages.first { $0.storeProduct.productIdentifier.contains("weekly") }

        if let package {
            let success = await purchaseVM.purchase(package: package)
            if success {
                ProgressTracker.shared.hasPremiumAccess = true
                vm.isSubscribed = true
                vm.skipPaywall()
            } else {
                purchaseError = "Purchase failed. Try again."
            }
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
            vm.isSubscribed = true
            vm.skipPaywall()
        } else {
            purchaseError = "No active purchases found."
        }
    }
}

// MARK: - Offer Type
enum OfferType {
    case weekly
    case yearly
}

// MARK: - Subviews

struct FeatureBulletCentered: View {
    let text: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.161, green: 0.145, blue: 0.141))
            Spacer()
        }
    }
}

struct OfferCard: View {
    let title: String
    let price: String
    let subtitle: String
    let offerType: OfferType
    let isSelected: Bool
    let onTap: () -> Void
    let accentColor: Color
    let textColor: Color

    private var badgeLabel: String? {
        switch offerType {
        case .weekly:   return "7 days free"
        case .yearly: return "Best value"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(textColor)
                    HStack(spacing: 4) {
                        Text(price)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(textColor)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? accentColor : Color(.systemGray3),
                            lineWidth: isSelected ? 0 : 1.5
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? accentColor.opacity(0.07) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? accentColor : Color(.systemGray4),
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(alignment: .topLeading) {
            if let label = badgeLabel {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(offerType == .weekly ? .white : Color(red: 0.773, green: 0.196, blue: 0.024))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(
                            offerType == .weekly
                                ? accentColor
                                : Color(red: 1.0, green: 0.957, blue: 0.929)
                        )
                    )
                    .overlay(
                        Capsule().stroke(
                            offerType == .weekly
                                ? Color.clear
                                : Color(red: 0.910, green: 0.314, blue: 0.039).opacity(0.3),
                            lineWidth: 0.5
                        )
                    )
                    .offset(x: 12, y: -11)
            }
        }
        .padding(.top, badgeLabel != nil ? 8 : 0)
    }
}

struct FreeTrialDueView: View {
    let primaryColor: Color
    let accentColor: Color
    let selectedOffer: OfferType

    var body: some View {
        HStack {
            Text("Due today")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            if selectedOffer == .yearly {
                Text("$39.99")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(primaryColor)
            } else {
                Text("$0.00")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(primaryColor)
                Text("· free for 7 days")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }
}
