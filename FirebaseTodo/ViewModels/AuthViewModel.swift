//
//  AuthViewModel.swift
//  FirebaseTodo
//
//  Email/password authentication with Firebase Auth.
//

import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published var errorMessage: String?
    @Published var infoMessage: String?
    @Published private(set) var isLoading = false

    var isSignedIn: Bool { user != nil }

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        user = Auth.auth().currentUser
        // Keeps `user` in sync (sign in, sign out, token revoked, app relaunch)
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.user = user }
        }
    }

    deinit {
        if let authHandle { Auth.auth().removeStateDidChangeListener(authHandle) }
    }

    // MARK: - Actions

    func signUp(email: String, password: String) async {
        guard validate(email: email, password: password) else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await Auth.auth().createUser(withEmail: email.trimmed, password: password)
        } catch {
            errorMessage = message(for: error)
        }
    }

    func signIn(email: String, password: String) async {
        guard validate(email: email, password: password) else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await Auth.auth().signIn(withEmail: email.trimmed, password: password)
        } catch {
            errorMessage = message(for: error)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPassword(email: String) async {
        guard email.trimmed.contains("@") else {
            errorMessage = "Enter your email address first."
            return
        }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email.trimmed)
            infoMessage = "Password reset email sent to \(email.trimmed)."
        } catch {
            errorMessage = message(for: error)
        }
    }

    // MARK: - Validation

    private func validate(email: String, password: String) -> Bool {
        guard email.trimmed.contains("@"), email.trimmed.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        return true
    }

    private func message(for error: Error) -> String {
        let authError = error as NSError
        let underlyingError = authError.userInfo[NSUnderlyingErrorKey] as? NSError
        let details = [authError.localizedFailureReason, underlyingError?.localizedDescription]
            .compactMap { $0 }
            .joined(separator: " ")
        if details.contains("CONFIGURATION_NOT_FOUND") {
            return "Firebase Authentication is not ready for this project. In the Firebase console, open Authentication, click Get started, then enable Email/Password under Sign-in method."
        }
        if authError.domain == AuthErrorDomain && authError.code == 17999 {
            return "Firebase Authentication reported an internal error (17999). Check that Authentication and Email/Password sign-in are enabled in the Firebase console."
        }
        return error.localizedDescription
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
