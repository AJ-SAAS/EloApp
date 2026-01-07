import Foundation
import RevenueCat
import Combine

@MainActor
final class PurchaseViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var offerings: Offerings?
    @Published var isLoading = false
    @Published var activeEntitlements: Set<String> = []

    init() {
        fetchOfferings()
        fetchCustomerInfo()
    }

    // MARK: - Fetch RevenueCat Offerings
    func fetchOfferings() {
        isLoading = true
        Purchases.shared.getOfferings { [weak self] offerings, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                print("Error fetching offerings:", error.localizedDescription)
            } else {
                self.offerings = offerings
            }
        }
    }

    // MARK: - Purchase Package
    func purchase(package: Package) async -> Bool {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.customerInfo.entitlements["premium_access"]?.isActive == true {
                self.activeEntitlements = Set(result.customerInfo.entitlements.active.keys)
                print("Purchase successful!")
                return true
            } else {
                print("Purchase completed but entitlement inactive")
                return false
            }
        } catch {
            print("Purchase failed:", error.localizedDescription)
            return false
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            self.activeEntitlements = Set(customerInfo.entitlements.active.keys)
            print("Restored successfully")
        } catch {
            print("Restore failed:", error.localizedDescription)
        }
    }

    // MARK: - Fetch Current Customer Info
    func fetchCustomerInfo() {
        Purchases.shared.getCustomerInfo { [weak self] info, error in
            if let info = info {
                self?.activeEntitlements = Set(info.entitlements.active.keys)
            }
        }
    }

    // MARK: - Check if user has premium
    func hasPremiumAccess() -> Bool {
        activeEntitlements.contains("premium_access")
    }
}
