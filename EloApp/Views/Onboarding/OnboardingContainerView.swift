import SwiftUI

struct OnboardingContainerView: View {

    @StateObject private var vm = OnboardingViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $vm.currentPage) {

                    // Welcome
                    WelcomeView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.welcome)

                    // Feature slides (edge-to-edge)
                    FeatureIntroView(
                        title: "Your Personal AI English Tutor",
                        subtitle: "Get instant feedback and guidance tailored just for you.",
                        imageName: "eloob3"
                    )
                    .tag(OnboardingViewModel.OnboardingPage.featureTutor)

                    FeatureIntroView(
                        title: "Track & Improve",
                        subtitle: "Elo shows you where to improve and helps you practice those skills.",
                        imageName: "eloob2"
                    )
                    .tag(OnboardingViewModel.OnboardingPage.featureFeedback)

                    FeatureIntroView(
                        title: "Progress & Grow",
                        subtitle: "Elo creates a personalized learning path for you.",
                        imageName: "eloob6"
                    )
                    .tag(OnboardingViewModel.OnboardingPage.featureProgress)

                    // Free trial / paywalls
                    FreeTrialToggleView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.freeTrialToggle1)

                    FreeTrialInfoView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.freeTrialInfo1)

                    PaywallView(vm: vm, showAuthInline: false)
                        .tag(OnboardingViewModel.OnboardingPage.paywall1)

                    // Questions
                    QuestionNameView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionName)
                    
                    QuestionShortTermGoalsView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionShortTermGoals)
                    
                    QuestionLongTermGoalsView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.questionLongTermGoals)

                    GoalsConfirmationView(vm: vm)  // ADD THIS
                        .tag(OnboardingViewModel.OnboardingPage.goalsConfirmation)

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

                    // Preparing Plan
                    PreparingPlanView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.preparingPlan)

                    // Second free trial / paywall
                    FreeTrialToggleView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.freeTrialToggle2)

                    FreeTrialInfoView(vm: vm)
                        .tag(OnboardingViewModel.OnboardingPage.freeTrialInfo2)

                    PaywallView(vm: vm, showAuthInline: true)
                        .environmentObject(authVM)
                        .tag(OnboardingViewModel.OnboardingPage.paywall2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: vm.currentPage)

                // Bottom buttons
                VStack {
                    if isFeaturePage {
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
    }

    // MARK: - Helpers
    private var isFeaturePage: Bool {
        [.featureTutor, .featureFeedback, .featureProgress].contains(vm.currentPage)
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
