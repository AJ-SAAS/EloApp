import Foundation
import SwiftUI
import Combine
import UserNotifications

@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Navigation
    @Published var currentPage: OnboardingPage = .welcome

    // MARK: - Personalization answers
    @Published var userName: String = ""
    @Published var nativeLanguage: String = ""
    @Published var englishLevel: String = ""
    @Published var selectedInterests: Set<String> = []
    @Published var improvementAreas: Set<String> = []
    @Published var dailyGoal: String = ""
    @Published var reminderTime: Date = Date()

    // MARK: - UI state
    @Published var showExitConfirmation = false

    // MARK: - Pages (unique rawValue)
    enum OnboardingPage: Int, CaseIterable, Hashable {
        case welcome
        case featureTutor
        case featureFeedback
        case featureProgress
        case freeTrialToggle1
        case freeTrialInfo1      // after first toggle
        case paywall1
        case questionName
        case questionNativeLang
        case questionLevel
        case questionInterests
        case questionAreas
        case questionGoal
        case questionReminder
        case questionNotifications
        case preparingPlan
        case freeTrialToggle2
        case freeTrialInfo2      // after second toggle
        case paywall2
        case authSetup
    }

    // MARK: - Navigation helpers

    /// Moves to the next page while skipping deleted pages
    func nextPage() {
        withAnimation {
            var nextRaw = currentPage.rawValue + 1

            while let candidate = OnboardingPage(rawValue: nextRaw),
                  !isValidPage(candidate) {
                nextRaw += 1
            }

            if let next = OnboardingPage(rawValue: nextRaw) {
                currentPage = next
            }
        }
    }

    /// Moves to the previous page
    func previousPage() {
        withAnimation {
            var prevRaw = currentPage.rawValue - 1

            while prevRaw >= 0,
                  let candidate = OnboardingPage(rawValue: prevRaw),
                  !isValidPage(candidate) {
                prevRaw -= 1
            }

            if prevRaw >= 0, let prev = OnboardingPage(rawValue: prevRaw) {
                currentPage = prev
            }
        }
    }

    /// Skips paywalls if needed
    func skipPaywall() {
        if currentPage == .paywall1 {
            currentPage = .questionName
        } else if currentPage == .paywall2 {
            currentPage = .authSetup
        }
    }

    /// Marks onboarding complete
    func completeOnboarding() {
        print("Onboarding completed")
    }

    /// Requests notification permission
    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    // MARK: - Helpers

    /// Checks if a page is valid (not deleted)
    private func isValidPage(_ page: OnboardingPage) -> Bool {
        switch page {
        // deleted pages like .scratchWin or .claimReward would return false
        default:
            return true
        }
    }
}
