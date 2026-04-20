import SwiftUI

struct TranslationTestView: View {
    @State private var translatedText = "Tap button to translate"
    @State private var isLoading = false
    
    let englishStrings = ["Welcome", "Place Order", "Settings"]
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(translatedText)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Translate to French 🇫🇷") {
                translate()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            if isLoading {
                ProgressView()
            }
        }
        .padding()
    }
    
    private func translate() {
        isLoading = true
        
        TranslationService.shared.translate(
            texts: englishStrings,
            to: "fr",
            context: "Mobile app"
        ) { translations in
            
            DispatchQueue.main.async {
                isLoading = false
                
                if let translations = translations {
                    translatedText = translations.first ?? "No result"
                    print("✅ Translations:", translations)
                } else {
                    translatedText = "❌ Failed"
                    print("❌ Translation failed")
                }
            }
        }
    }
}
