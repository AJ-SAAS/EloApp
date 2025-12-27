// Views/Onboarding/QuestionNativeLanguageView.swift

import SwiftUI   // ← THIS WAS MISSING

struct QuestionNativeLanguageView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var showAllLanguages = false
    
    let topLanguages = ["English 🇺🇸", "Español 🇪🇸", "Türkçe 🇹🇷", "中文 🇨🇳", "Português 🇵🇹"]
    
    // Add more languages as needed
    let allLanguages = [
        "English 🇺🇸", "Español 🇪🇸", "Français 🇫🇷", "Deutsch 🇩🇪",
        "Italiano 🇮🇹", "Русский 🇷🇺", "العربية 🇸🇦", "हिन्दी 🇮🇳",
        "日本語 🇯🇵", "한국어 🇰🇷", "Nederlands 🇳🇱", "Polski 🇵🇱"
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("What's your native language?")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            ForEach(topLanguages, id: \.self) { lang in
                Button(action: {
                    vm.nativeLanguage = lang
                    vm.nextPage()
                }) {
                    Text(lang)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.nativeLanguage == lang ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            
            Button("More") {
                showAllLanguages = true
            }
            .font(.title3)
            .foregroundColor(.blue)
            .padding(.top)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showAllLanguages) {
            NavigationView {
                List(allLanguages, id: \.self) { lang in
                    Button(action: {
                        vm.nativeLanguage = lang
                        showAllLanguages = false
                        vm.nextPage()
                    }) {
                        HStack {
                            Text(lang)
                            Spacer()
                            if vm.nativeLanguage == lang {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .navigationTitle("Select Language")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") { showAllLanguages = false }
                    }
                }
            }
        }
    }
}
