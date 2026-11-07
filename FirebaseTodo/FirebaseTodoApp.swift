import SwiftUI
import FirebaseCore

@main
struct FirebaseTodoApp: App {
    private let isFirebaseConfigured: Bool

    init() {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: path) {
            FirebaseApp.configure(options: options)
            isFirebaseConfigured = true
        } else {
            isFirebaseConfigured = false
        }
    }

    var body: some Scene {
        WindowGroup {
            if isFirebaseConfigured {
                ConfiguredRootView()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checklist")
                        .font(.largeTitle)
                    Text("Firebase setup needed")
                        .font(.title2.bold())
                    Text("Add GoogleService-Info.plist to the FirebaseTodo app target in Xcode, then run again.")
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
    }
}

private struct ConfiguredRootView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        RootView()
            .environmentObject(authViewModel)
    }
}
