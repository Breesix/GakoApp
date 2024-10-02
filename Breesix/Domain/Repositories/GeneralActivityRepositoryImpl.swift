//
//  GeneralActivityRepositoryImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 02/10/24.
//

import Foundation
import SwiftData

class GeneralActivityRepositoryImpl: GeneralActivityRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func addActivity(_ note: Activity, for student: Student) async throws {
        student.notes.append(note)
        try context.save()
    }

    func getActivitiesForStudent(_ student: Student) async throws -> [Activity] {
        return student.notes
    }
    
    func updateActivity(_ note: Activity) async throws {
        try context.save()
    }
    
    func deleteActivity(_ note: Activity, from student: Student) async throws {
        student.notes.removeAll { $0.id == note.id }
        context.delete(note)
        try context.save()
    }

}
