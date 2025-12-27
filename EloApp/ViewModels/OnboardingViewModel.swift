// ViewModels/OnboardingViewModel.swift

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

    // MARK: - Scratch / UI state
    @Published var scratchedCards: Set<Int> = []
    @Published var showExitConfirmation = false

    // MARK: - Pages (IMPORTANT: Hashable via Int rawValue)
    enum OnboardingPage: Int, CaseIterable, Hashable {
        case welcome
        case featureTutor
        case featureFeedback
        case featureProgress
        case freeTrialToggle1
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
        case paywall2
        case scratchWin
        case claimReward
        case authSetup
    }

    // MARK: - Navigation helpers
    func nextPage() {
        withAnimation {
            if let next = OnboardingPage(rawValue: currentPage.rawValue + 1) {
                currentPage = next
            }
        }
    }

    func skipPaywall() {
        if currentPage == .paywall1 {
            currentPage = .questionName
        } else if currentPage == .paywall2 {
            currentPage = .scratchWin
        }
    }

    func completeOnboarding() {
        // Persist flag here if needed
        print("Onboarding completed")
    }

    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
}
