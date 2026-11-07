//
//  TaskListView.swift
//  FirebaseTodo
//
//  Shows the user's tasks: add (+), edit (tap), complete (checkbox),
//  delete (swipe), sign out (top-left menu).
//

import SwiftUI

struct TaskListView: View {
    let userId: String
    let email: String

    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var viewModel = TaskViewModel()
    @State private var activeSheet: TaskSheet?

    private enum TaskSheet: Identifiable {
        case add
        case edit(TodoTask)

        var id: String {
            switch self {
            case .add: return "add"
            case .edit(let task): return task.id ?? UUID().uuidString
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.tasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Text(email)
                        Button("Sign Out", role: .destructive) {
                            viewModel.stop()
                            authViewModel.signOut()
                        }
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .add
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add:
                    TaskFormView(task: nil) { title, description in
                        viewModel.addTask(title: title, description: description)
                    }
                case .edit(let task):
                    TaskFormView(task: task) { title, description in
                        viewModel.updateTask(task, title: title, description: description)
                    }
                }
            }
            .alert("Error", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear { viewModel.start(userId: userId) }
    }

    // MARK: - Subviews

    private var taskList: some View {
        List {
            ForEach(viewModel.tasks) { task in
                HStack(alignment: .top, spacing: 12) {
                    Button {
                        viewModel.toggleCompleted(task)
                    } label: {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(task.isCompleted ? Color.green : Color.secondary)
                    }
                    .buttonStyle(.borderless)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.headline)
                            .strikethrough(task.isCompleted)
                        if !task.description.isEmpty {
                            Text(task.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { activeSheet = .edit(task) }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteTask(task)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        activeSheet = .edit(task)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No tasks yet")
                .font(.title3.bold())
            Text("Tap + to add your first task.")
                .foregroundStyle(.secondary)
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } })
    }
}
