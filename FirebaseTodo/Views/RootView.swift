//
//  RootView.swift
//  FirebaseTodo
//
//  Chooses between the login screen and the task list.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        if let user = authViewModel.user {
            TaskListView(userId: user.uid, email: user.email ?? "")
                .id(user.uid)   // fresh view model if a different user signs in
        } else {
            AuthView()
        }
    }
}
