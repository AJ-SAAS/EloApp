import SwiftUI

struct WelcomeView: View {
    let vm: OnboardingViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @State private var currentImageIndex = 0
    @State private var hasAutoSwiped = false
    private let images = ["eloob5", "eloob1"]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // IMAGE SLIDER – fills ~60–65% of screen height
                TabView(selection: $currentImageIndex) {
                    ForEach(0..<images.count, id: \.self) { index in
                        Image(images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width,
                                   height: geo.size.height * 0.65)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onAppear {
                    // One-time auto-swipe after 1 second
                    guard !hasAutoSwiped else { return }
                    hasAutoSwiped = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentImageIndex = 1
                        }
                    }
                }

                // TEXT
                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome to Elo!")
                        .font(.system(size: 36, weight: .regular, design: .serif))

                    Text("Boost your language skills with Elo effortlessly anytime, anywhere.")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer() // pushes buttons to bottom

                // BUTTONS (only Log in + Let's Go)
                VStack(spacing: 16) {
                    Button("Log in") { authVM.completeOnboarding() }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)

                    Button("Let's Go") { vm.nextPage() }
                        .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}
