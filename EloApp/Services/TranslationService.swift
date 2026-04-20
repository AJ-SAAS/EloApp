import Foundation

struct TranslationRequest: Codable {
    let source_texts: [String]
    let target_language: String
    let context: String
}

struct TranslationResponse: Codable {
    let translations: [String]
}

class TranslationService {
    
    static let shared = TranslationService()
    
    // ✅ Add /translate endpoint
    private let baseURL = "https://pleasing-growth-production.up.railway.app/translate"
    
    private init() {}
    
    // MARK: - Basic translate
    func translate(
        texts: [String],
        to language: String,
        context: String,
        completion: @escaping ([String]?) -> Void
    ) {
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid URL")
            completion(nil)
            return
        }
        
        let body = TranslationRequest(
            source_texts: texts,
            target_language: language,
            context: context
        )
        
        guard let jsonData = try? JSONEncoder().encode(body) else {
            print("❌ Failed to encode JSON")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error)
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("❌ No data returned")
                completion(nil)
                return
            }
            
            if let str = String(data: data, encoding: .utf8) {
                print("💬 Server response:", str)
            }
            
            do {
                let result = try JSONDecoder().decode(TranslationResponse.self, from: data)
                completion(result.translations)
            } catch {
                print("❌ Decoding error:", error)
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Async fetch for settings
    func fetchTranslations(for language: String) async -> [String: String] {
        let keys = [
            "ACCOUNT", "EMAIL", "RESET_PASSWORD", "NOT_SIGNED_IN",
            "PREFERENCES", "DAILY_NOTIFICATIONS", "ENABLE_SOUNDS",
            "VOICE", "DIFFICULTY", "LANGUAGE",
            "VOICE_ACCESS", "MICROPHONE", "SPEECH_RECOGNITION", "OPEN_SETTINGS",
            "SUBSCRIPTIONS", "PREMIUM_ACTIVE", "FULL_ACCESS", "GET_PREMIUM",
            "MANAGE_SUBSCRIPTION", "RESTORE_SUBSCRIPTION",
            "GENERAL", "WEBSITE", "PRIVACY_POLICY", "TERMS_OF_USE",
            "CONTACT_US", "SHARE_FEEDBACK",
            "ACCOUNT_ACTIONS", "SIGN_OUT", "DELETE_ACCOUNT",
            "SETTINGS"
        ]
        
        let english = [
            "Account", "Email", "Reset Password", "Not signed in",
            "Preferences", "Daily Notifications", "Enable Sounds",
            "Voice", "Difficulty", "Language",
            "Voice Access", "Microphone", "Speech Recognition", "Open Settings",
            "Subscriptions", "Premium Active", "You have full access", "Get Premium",
            "Manage Subscription", "Restore Subscription",
            "General", "Website", "Privacy Policy", "Terms of Use",
            "Contact Us", "Share Feedback",
            "Account Actions", "Sign Out", "Delete Account",
            "Settings"
        ]
        
        return await withCheckedContinuation { continuation in
            self.translate(
                texts: english,
                to: language,
                context: "Mobile app settings UI"
            ) { result in
                var dict: [String: String] = [:]
                
                if let result = result {
                    for (key, value) in zip(keys, result) {
                        dict[key] = value
                    }
                } else {
                    print("❌ Translation result was nil")
                }
                
                continuation.resume(returning: dict)
            }
        }
    }
}
