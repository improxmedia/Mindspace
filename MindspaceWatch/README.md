# Mindspace WatchOS Standalone App

This is a standalone Apple Watch application (WatchOS 9+) designed for cellular Apple Watch Series 8.
It allows you to log Urges using Voice Dictation directly to your Firebase Database without needing your iPhone nearby.

## Setup Instructions

1. Open Xcode, select **File > New > Project...**
2. Choose **watchOS > App** and name it `MindspaceWatch`.
3. Select **SwiftUI** for Interface and **Swift** for Language.
4. Replace the generated `ContentView.swift` and `MindspaceWatchApp.swift` with the ones provided in this directory.
5. Add the **Firebase iOS SDK** via Swift Package Manager (File > Add Packages). Add `FirebaseFirestore` and `FirebaseAuth`.
6. Add your `GoogleService-Info.plist` (downloaded from your Firebase Console for the iOS App) into the Watch App folder.
7. Build and run on your Apple Watch or Apple Watch Simulator!

## Features

- **Standalone Cellular Support**: Syncs directly to Firebase from the Apple Watch.
- **Urge Button**: A large red button to trigger the urge flow.
- **Voice Dictation**: Uses native watchOS text dictation to capture the urge.
- **Database Sync**: Directly pushes the captured entry to your existing Firebase Firestore database used by your PWA.
