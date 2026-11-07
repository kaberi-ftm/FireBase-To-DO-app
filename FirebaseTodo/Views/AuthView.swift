//
//  AuthView.swift
//  FirebaseTodo
//
//  Sign in / Sign up screen (email + password).
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    private enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Sign Up"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var passwordsMatch: Bool { mode == .signIn || password == confirmPassword }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checklist")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                    .padding(.top, 40)

                Text("Todo List")
                    .font(.largeTitle.bold())
                Text(mode == .signIn ? "Welcome back" : "Create your account")
                    .foregroundStyle(.secondary)

                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))

                    SecureField("Password", text: $password)
                        .textContentType(mode == .signIn ? .password : .newPassword)
                        .padding()
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))

                    if mode == .signUp {
                        SecureField("Confirm password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
                        if !confirmPassword.isEmpty && !passwordsMatch {
                            Text("Passwords do not match")
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                Button {
                    submit()
                } label: {
                    Group {
                        if authViewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(mode.rawValue).bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                }
                .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty || !passwordsMatch)

                if mode == .signIn {
                    Button("Forgot password?") {
                        Task { await authViewModel.resetPassword(email: email) }
                    }
                    .font(.footnote)
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: mode) { _ in
            confirmPassword = ""
            authViewModel.errorMessage = nil
        }
        .alert("Error", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
        .alert("Done", isPresented: infoBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authViewModel.infoMessage ?? "")
        }
    }

    private func submit() {
        Task {
            switch mode {
            case .signIn: await authViewModel.signIn(email: email, password: password)
            case .signUp: await authViewModel.signUp(email: email, password: password)
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { authViewModel.errorMessage != nil },
                set: { if !$0 { authViewModel.errorMessage = nil } })
    }

    private var infoBinding: Binding<Bool> {
        Binding(get: { authViewModel.infoMessage != nil },
                set: { if !$0 { authViewModel.infoMessage = nil } })
    }
}
