import FirebaseAuth
import FirebaseFirestore

final class FirebaseManager {

    static let shared = FirebaseManager()

    let auth = Auth.auth()
    let db = Firestore.firestore()

    private init() {}

    // MARK: - Auth helpers

    var currentUser: User? {
        auth.currentUser
    }

    var hasEmailProvider: Bool {
        auth.currentUser?.providerData.contains {
            $0.providerID == "password"
        } ?? false
    }

    func signOut() throws {
        try auth.signOut()
    }

    // MARK: - Email Auth

    func register(
        email: String,
        password: String,
        displayName: String
    ) async throws {

        let result = try await auth.createUser(
            withEmail: email,
            password: password
        )

        let uid = result.user.uid

        try await db.collection("users")
            .document(uid)
            .setData([
                "displayName": displayName,
                "email": email,
                "createdAt": Timestamp()
            ], merge: true)
    }

    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
}
