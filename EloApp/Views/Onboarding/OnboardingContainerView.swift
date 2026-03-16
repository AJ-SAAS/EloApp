import SwiftUI

struct OnboardingContainerView: View {

    @StateObject private var vm = OnboardingViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Page Content
                ZStack {
                    switch vm.currentPage {

                    case .welcome:
                        WelcomeView(vm: vm)

                    case .featureTutor:
                        FeatureIntroView(
                            title: "Your Personal AI English Tutor",
                            subtitle: "Get instant feedback and guidance tailored just for you.",
                            imageName: "eloob3"
                        )

                    case .featureFeedback:
                        FeatureIntroView(
                            title: "Track & Improve",
                            subtitle: "Elo shows you where to improve and helps you practice those skills.",
                            imageName: "eloob2"
                        )

                    case .featureProgress:
                        FeatureIntroView(
                            title: "Progress & Grow",
                            subtitle: "Elo creates a personalized learning path for you.",
                            imageName: "eloob6"
                        )

                    case .freeTrialToggle1, .freeTrialToggle2:
                        FreeTrialToggleView(vm: vm)

                    case .freeTrialInfo1, .freeTrialInfo2:
                        FreeTrialInfoView(vm: vm)

                    case .paywall1:
                        PaywallView(vm: vm, showAuthInline: false)
                            .environmentObject(authVM)

                    case .paywall2:
                        PaywallView(vm: vm, showAuthInline: true)
                            .environmentObject(authVM)

                    case .questionName:
                        QuestionNameView(vm: vm)

                    case .scientificMethod:
                        ScientificMethodView(vm: vm)

                    case .questionShortTermGoals:
                        QuestionShortTermGoalsView(vm: vm)

                    case .questionLongTermGoals:
                        QuestionLongTermGoalsView(vm: vm)

                    case .goalsConfirmation:
                        GoalsConfirmationView(vm: vm)

                    case .questionNativeLang:
                        QuestionNativeLanguageView(vm: vm)

                    case .questionLevel:
                        QuestionEnglishLevelView(vm: vm)

                    case .questionInterests:
                        QuestionInterestsView(vm: vm)

                    case .questionAreas:
                        QuestionImprovementAreasView(vm: vm)

                    case .questionGoal:
                        QuestionDailyGoalView(vm: vm)

                    case .questionReminder:
                        QuestionReminderTimeView(vm: vm)

                    case .questionNotifications:
                        QuestionNotificationsView(vm: vm)

                    case .preparingPlan:
                        PreparingPlanView(vm: vm)

                    case .authSetup:
                        AuthView()
                            .environmentObject(authVM)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .id(vm.currentPage)

                // MARK: - Bottom Buttons
                VStack {
                    if isFeaturePage || vm.currentPage == .scientificMethod {
                        Button("Continue") { vm.nextPage() }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding()
                    } else if isQuestionPage {
                        Button("Next") { vm.nextPage() }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding()
                            .disabled(!isCurrentQuestionValid())
                    } else if vm.currentPage == .preparingPlan {
                        Button("Get My Plan") { vm.nextPage() }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding()
                    } else if isFreeTrialInfoPage {
                        Button("Show Plans") { vm.nextPage() }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await vm.runSkipPaywallsIfNeeded(authVM: authVM)
            }
        }
    }

    // MARK: - Helpers

    private var isFeaturePage: Bool {
        [.featureTutor, .featureFeedback, .featureProgress].contains(vm.currentPage)
    }

    private var isQuestionPage: Bool {
        [
            .questionName,
            .scientificMethod,
            .questionShortTermGoals,
            .questionLongTermGoals,
            .goalsConfirmation,
            .questionNativeLang,
            .questionLevel,
            .questionInterests,
            .questionAreas,
            .questionGoal,
            .questionReminder,
            .questionNotifications
        ].contains(vm.currentPage)
    }

    private var isFreeTrialInfoPage: Bool {
        [.freeTrialInfo1, .freeTrialInfo2].contains(vm.currentPage)
    }

    private func isCurrentQuestionValid() -> Bool {
        switch vm.currentPage {
        case .questionName:
            return !vm.userName.trimmingCharacters(in: .whitespaces).isEmpty
        case .questionShortTermGoals:
            return !vm.shortTermGoals.isEmpty
        case .questionLongTermGoals:
            return !vm.longTermGoal.isEmpty
        case .questionNativeLang:
            return !vm.nativeLanguage.isEmpty
        case .questionLevel:
            return !vm.englishLevel.isEmpty
        case .questionInterests:
            return vm.selectedInterests.count > 0 && vm.selectedInterests.count <= 4
        case .questionAreas:
            return !vm.improvementAreas.isEmpty
        case .questionGoal:
            return !vm.dailyGoal.isEmpty
        default:
            return true
        }
    }
}

// MARK: - OnboardingViewModel extension

extension OnboardingViewModel {
    @MainActor
    func runSkipPaywallsIfNeeded(authVM: AuthViewModel) async {
        if authVM.isSignedIn || isSubscribed {
            isSubscribed = true
            if isPaywall(currentPage) {
                nextPage()
            }
        }
    }
}
