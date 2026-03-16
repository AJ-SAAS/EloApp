import Foundation
import SwiftUI
import Combine
import UserNotifications

@MainActor
final class OnboardingViewModel: ObservableObject {

    @Published var currentPage: OnboardingPage = .welcome

    @Published var userName: String = ""
    @Published var shortTermGoals: Set<String> = []
    @Published var longTermGoal: String = ""
    @Published var nativeLanguage: String = ""
    @Published var englishLevel: String = ""
    @Published var selectedInterests: Set<String> = []
    @Published var improvementAreas: Set<String> = []
    @Published var dailyGoal: String = ""
    @Published var reminderTime: Date = Date()

    @Published var showExitConfirmation = false
    @Published var isSubscribed: Bool = false

    // MARK: - Onboarding Pages
    enum OnboardingPage: Int, CaseIterable, Hashable {
        case welcome
        case featureTutor
        case featureFeedback
        case featureProgress
        case freeTrialToggle1
        case freeTrialInfo1
        case paywall1
        case questionName
        case scientificMethod
        case questionShortTermGoals
        case questionLongTermGoals
        case goalsConfirmation
        case questionNativeLang
        case questionLevel
        case questionInterests
        case questionAreas
        case questionGoal
        case questionReminder
        case questionNotifications
        case preparingPlan
        case freeTrialToggle2
        case freeTrialInfo2
        case paywall2
        case authSetup
    }

    // MARK: - Navigation
    func nextPage() {
        hideKeyboard()
        withAnimation {
            var nextRaw = currentPage.rawValue + 1
            while let candidate = OnboardingPage(rawValue: nextRaw) {
                if isValidPage(candidate) { break }
                nextRaw += 1
            }
            if let next = OnboardingPage(rawValue: nextRaw) {
                currentPage = next
            }
        }
    }

    func previousPage() {
        hideKeyboard()
        withAnimation {
            var prevRaw = currentPage.rawValue - 1
            while prevRaw >= 0, let candidate = OnboardingPage(rawValue: prevRaw) {
                if isValidPage(candidate) { break }
                prevRaw -= 1
            }
            if prevRaw >= 0, let prev = OnboardingPage(rawValue: prevRaw) {
                currentPage = prev
            }
        }
    }

    func skipPaywall() {
        // Only skip if user explicitly presses "X"
        if currentPage == .paywall1 || currentPage == .paywall2 {
            nextPage()
        }
    }

    func completeOnboarding() {
        ProgressTracker.shared.markOnboardingCompleted()
        print("✅ Onboarding completed")
    }

    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    // MARK: - Page Validation
    private func isValidPage(_ page: OnboardingPage) -> Bool {
        switch page {
        case .paywall1,
             .paywall2,
             .freeTrialToggle1,
             .freeTrialInfo1,
             .freeTrialToggle2,
             .freeTrialInfo2:
            return !isSubscribed
        default:
            return true
        }
    }

    func isPaywall(_ page: OnboardingPage) -> Bool {
        [
            .paywall1,
            .paywall2,
            .freeTrialToggle1,
            .freeTrialInfo1,
            .freeTrialToggle2,
            .freeTrialInfo2
        ].contains(page)
    }

    // MARK: - Helpers
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        #endif
    }
}
