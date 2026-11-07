//
//  TaskViewModel.swift
//  FirebaseTodo
//
//  CRUD for the signed-in user's tasks in Cloud Firestore.
//  Data path: users/{uid}/tasks/{taskId}
//

import Foundation
import FirebaseFirestore

final class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [TodoTask] = []
    @Published private(set) var isLoading = true
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var userId: String?

    deinit { listener?.remove() }

    private func tasksCollection(_ uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("tasks")
    }

    // MARK: - READ (real-time listener)

    func start(userId: String) {
        guard self.userId != userId else { return }
        stop()
        self.userId = userId
        isLoading = true

        listener = tasksCollection(userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.tasks = snapshot?.documents.compactMap {
                    try? $0.data(as: TodoTask.self)
                } ?? []
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
        userId = nil
        tasks = []
    }

    // MARK: - CREATE

    func addTask(title: String, description: String) {
        guard let uid = userId else { return }
        let task = TodoTask(title: title, description: description)
        do {
            _ = try tasksCollection(uid).addDocument(from: task) { [weak self] error in
                self?.report(error)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - UPDATE

    func updateTask(_ task: TodoTask, title: String, description: String) {
        guard let uid = userId, let id = task.id else { return }
        tasksCollection(uid).document(id).updateData([
            "title": title,
            "description": description
        ]) { [weak self] error in
            self?.report(error)
        }
    }

    func toggleCompleted(_ task: TodoTask) {
        guard let uid = userId, let id = task.id else { return }
        tasksCollection(uid).document(id).updateData([
            "isCompleted": !task.isCompleted
        ]) { [weak self] error in
            self?.report(error)
        }
    }

    // MARK: - DELETE

    func deleteTask(_ task: TodoTask) {
        guard let uid = userId, let id = task.id else { return }
        tasksCollection(uid).document(id).delete { [weak self] error in
            self?.report(error)
        }
    }

    // MARK: - Helpers

    private func report(_ error: Error?) {
        if let error { errorMessage = error.localizedDescription }
    }
}
