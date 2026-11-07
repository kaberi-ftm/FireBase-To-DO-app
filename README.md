# Firebase Todo List

Mobile Computing lab project built with SwiftUI, Firebase Authentication, and Cloud Firestore.

## Requirements

- Xcode 26.2 or newer
- iOS 16.0 or newer
- Internet connection for Firebase Authentication and Firestore

## Run the app

1. Open `FirebaseTodo.xcodeproj` in Xcode.
2. Select the `FirebaseTodo` scheme and an iPhone simulator.
3. Press Run (⌘R). Xcode will resolve the Firebase Swift packages if they are not already cached.

`FirebaseTodo/GoogleService-Info.plist` is included in the Xcode app target. The app uses the registered bundle identifier `com.example.FirebaseTodo`. Email/Password sign-in is enabled in the connected Firebase project. The Firestore rules are provided in `firestore.rules` and must be published in the Firebase console for task access.

## Features

- Create an account, sign in, sign out, and request a password reset.
- Add, edit, complete, and delete tasks.
- Store each user's tasks at `users/{uid}/tasks/{taskId}` in Cloud Firestore.
- Display task updates through a Firestore snapshot listener.

## Project files

- `FirebaseTodo/FirebaseTodoApp.swift` — app entry point and Firebase initialization
- `FirebaseTodo/Models/TodoTask.swift` — task model
- `FirebaseTodo/ViewModels/` — authentication and task operations
- `FirebaseTodo/Views/` — SwiftUI screens
- `firestore.rules` — per-user Firestore access rules
