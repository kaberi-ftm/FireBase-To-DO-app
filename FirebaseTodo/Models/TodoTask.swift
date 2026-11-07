//
//  TodoTask.swift
//  FirebaseTodo
//
//  Firestore document: users/{uid}/tasks/{taskId}
//

import Foundation
import FirebaseFirestore

struct TodoTask: Identifiable, Codable, Equatable {
    @DocumentID var id: String?      // filled in automatically by Firestore
    var title: String
    var description: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()
}
