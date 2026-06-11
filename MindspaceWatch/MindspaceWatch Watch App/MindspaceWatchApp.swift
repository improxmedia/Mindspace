import SwiftUI
import FirebaseCore

@main
struct MindspaceWatch_Watch_AppApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
