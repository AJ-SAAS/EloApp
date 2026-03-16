import SwiftUI

struct QuestionNativeLanguageView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var showAllLanguages = false

    let topLanguages = [
        "🇬🇧 English",
        "🇪🇸 Español",
        "🇹🇷 Türkçe",
        "🇨🇳 中文",
        "🇵🇹 Português"
    ]

    let allLanguages = [
        "🇬🇧 English", "🇪🇸 Español", "🇫🇷 Français", "🇩🇪 Deutsch",
        "🇮🇹 Italiano", "🇷🇺 Русский", "🇸🇦 العربية", "🇮🇳 हिन्दी",
        "🇯🇵 日本語", "🇰🇷 한국어", "🇳🇱 Nederlands", "🇵🇱 Polski",
        "🇮🇩 Indonesian", "🇧🇩 Bengali", "🇮🇳 Hindi", "🇵🇰 Urdu",
        "🇹🇿 Swahili", "🇮🇷 فارسی (Farsi)", "🇳🇬 Hausa", "🇻🇳 Tiếng Việt",
        "🇹🇭 ไทย", "🇬🇷 Ελληνικά"
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 30) {
                Spacer().frame(height: 60)

                Text("What's your native language?")
                    .font(.system(size: 36, weight: .regular, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(topLanguages, id: \.self) { lang in
                    Button {
                        vm.nativeLanguage = lang
                    } label: {
                        HStack {
                            Text(lang)
                                .font(.system(size: 20, weight: .semibold))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            if vm.nativeLanguage == lang {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(vm.nativeLanguage == lang ? .white : .primary)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(vm.nativeLanguage == lang
                                    ? Color.eloTeal
                                    : Color.eloTeal.opacity(0.07))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    vm.nativeLanguage == lang
                                        ? Color.eloTeal
                                        : Color.eloTeal.opacity(0.15),
                                    lineWidth: 1
                                )
                        )
                    }
                }
                .padding(.horizontal)

                Button("More languages") {
                    showAllLanguages = true
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.eloTeal)
                .padding(.top, 4)

                Spacer()
            }
            .padding(.horizontal)

            Button { vm.previousPage() } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
            }
            .padding(.top, 50)
            .padding(.leading, 12)
        }
        .sheet(isPresented: $showAllLanguages) {
            NavigationView {
                List(allLanguages, id: \.self) { lang in
                    Button {
                        vm.nativeLanguage = lang
                        showAllLanguages = false
                    } label: {
                        HStack {
                            Text(lang)
                                .font(.system(size: 20, weight: .regular))
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(.primary)
                            Spacer()
                            if vm.nativeLanguage == lang {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.eloTeal)
                                    .font(.headline.bold())
                            }
                        }
                    }
                }
                .navigationTitle("Select Language")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { showAllLanguages = false }
                            .foregroundColor(.eloTeal)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
