//
//  TaskFormView.swift
//  FirebaseTodo
//
//  One form used for both "Add task" (task == nil) and "Edit task".
//

import SwiftUI

struct TaskFormView: View {
    let task: TodoTask?
    let onSave: (_ title: String, _ description: String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String

    init(task: TodoTask?, onSave: @escaping (String, String) -> Void) {
        self.task = task
        self.onSave = onSave
        _title = State(initialValue: task?.title ?? "")
        _description = State(initialValue: task?.description ?? "")
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("e.g. Finish lab report", text: $title)
                }
                Section("Description") {
                    TextField("Details (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(trimmedTitle,
                               description.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
