import SwiftUI

struct OnboardingContainerView: View {

    @StateObject private var vm = OnboardingViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {

                TabView(selection: $vm.currentPage) {

                    // MARK: - Welcome / Feature Intro
                    WelcomeView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.welcome)

                    FeatureIntroView(
                        title: "Your Personal Private Tutor",
                        subtitle: "Experience learning with your own welcoming virtual teacher."
                    )
                    .tag(OnboardingViewModel.OnboardingPage.featureTutor)

                    FeatureIntroView(
                        title: "Feedback & Improve",
                        subtitle: "Elo identifies your improvement areas and encourages you to develop them."
                    )
                    .tag(OnboardingViewModel.OnboardingPage.featureFeedback)

                    FeatureIntroView(
                        title: "Progress & Grow",
                        subtitle: "Elo creates a personalized learning path for you."
                    )
                    .tag(OnboardingViewModel.OnboardingPage.featureProgress)

                    // MARK: - First Free Trial Toggle
                    FreeTrialToggleView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.freeTrialToggle1)

                    // ✅ NEW: Free Trial Info after first toggle
                    FreeTrialInfoView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.freeTrialInfo1)

                    // First paywall
                    PaywallView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.paywall1)

                    // MARK: - Questions
                    QuestionNameView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionName)

                    QuestionNativeLanguageView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionNativeLang)

                    QuestionEnglishLevelView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionLevel)

                    QuestionInterestsView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionInterests)

                    QuestionImprovementAreasView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionAreas)

                    QuestionDailyGoalView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionGoal)

                    QuestionReminderTimeView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionReminder)

                    QuestionNotificationsView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionNotifications)

                    // MARK: - Preparing Plan
                    PreparingPlanView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.preparingPlan)

                    // MARK: - Second Free Trial Toggle
                    FreeTrialToggleView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.freeTrialToggle2)

                    // ✅ NEW: Free Trial Info after second toggle
                    FreeTrialInfoView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.freeTrialInfo2)

                    // Second paywall
                    PaywallView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.paywall2)

                    // MARK: - Auth Setup
                    AuthSetupView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.authSetup)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: vm.currentPage)

                // MARK: - Bottom CTA Button Logic
                if isFeaturePage {
                    Button("Continue") {
                        vm.nextPage()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
                else if isQuestionPage {
                    Button("Next") {
                        vm.nextPage()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                    .disabled(!isCurrentQuestionValid())
                }
                else if vm.currentPage == .preparingPlan {
                    Button("Get My Plan") {
                        vm.nextPage()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
                else if isFreeTrialInfoPage {
                    Button("Show Plans") {
                        vm.nextPage()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
            }
        }
    }

    // MARK: - Helpers
    private var isFeaturePage: Bool {
        vm.currentPage == .featureTutor ||
        vm.currentPage == .featureFeedback ||
        vm.currentPage == .featureProgress
    }

    private var isQuestionPage: Bool {
        vm.currentPage.rawValue >= OnboardingViewModel.OnboardingPage.questionName.rawValue &&
        vm.currentPage.rawValue <= OnboardingViewModel.OnboardingPage.questionNotifications.rawValue
    }

    private var isFreeTrialInfoPage: Bool {
        vm.currentPage == .freeTrialInfo1 || vm.currentPage == .freeTrialInfo2
    }

    private func isCurrentQuestionValid() -> Bool {
        switch vm.currentPage {
        case .questionName:
            return !vm.userName.trimmingCharacters(in: .whitespaces).isEmpty
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
