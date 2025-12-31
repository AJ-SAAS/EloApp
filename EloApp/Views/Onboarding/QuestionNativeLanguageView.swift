import SwiftUI

struct QuestionNativeLanguageView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var showAllLanguages = false

    let topLanguages = ["English 🇺🇸", "Español 🇪🇸", "Türkçe 🇹🇷", "中文 🇨🇳", "Português 🇵🇹"]
    let allLanguages = [
        "English 🇺🇸", "Español 🇪🇸", "Français 🇫🇷", "Deutsch 🇩🇪",
        "Italiano 🇮🇹", "Русский 🇷🇺", "العربية 🇸🇦", "हिन्दी 🇮🇳",
        "日本語 🇯🇵", "한국어 🇰🇷", "Nederlands 🇳🇱", "Polski 🇵🇱"
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {

            VStack(spacing: 30) {

                Spacer().frame(height: 40)

                Text("What's your native language?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                ForEach(topLanguages, id: \.self) { lang in
                    Button {
                        vm.nativeLanguage = lang
                    } label: {
                        Text(lang)
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(vm.nativeLanguage == lang ? .white : .primary)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(vm.nativeLanguage == lang ? Color.purple : Color.gray.opacity(0.1))
                            )
                    }
                }

                Button("More languages") {
                    showAllLanguages = true
                }
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.top)

                Spacer()
            }
            .padding()

            // Back button
            Button {
                vm.previousPage()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .padding()
            }
        }
        .sheet(isPresented: $showAllLanguages) {
            NavigationView {
                List(allLanguages, id: \.self) { lang in
                    Button {
                        vm.nativeLanguage = lang
                    } label: {
                        HStack {
                            Text(lang)
                                .font(.title3)
                            Spacer()
                            if vm.nativeLanguage == lang {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.purple)
                                    .font(.headline.bold())
                            }
                        }
                    }
                }
                .navigationTitle("Select Language")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showAllLanguages = false
                        }
                    }
                }
            }
        }
    }
}
