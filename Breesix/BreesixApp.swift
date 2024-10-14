//
//  BreesixApp.swift
//  Breesix
//
//  Created by Rangga Biner on 19/09/24.
//

import SwiftUI
import SwiftData

@main
struct BreesixApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Student.self, Note.self)
        } catch {
            fatalError("Failed to create ModelContainer for Student and Activity: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            let context = container.mainContext
            
            let studentDataSource = StudentDataSourceImpl(context: context)
            let studentRepository = StudentRepositoryImpl(dataSource: studentDataSource)
            let studentUseCase = StudentUseCaseImpl(repository: studentRepository)
            
            let noteDataSource = NoteDataSourceImpl(context: context)
            let noteRepository = NoteRepositoryImpl(dataSource: noteDataSource)
            let noteUseCases = NoteUseCaseImpl(repository: noteRepository)
            
            let activityDataSource = ActivityDataSourceImpl(context: context)
            let activityRepository = ActivityRepositoryImpl(activityDataSource: activityDataSource)
            let activityUseCase = ActivityUseCaseImpl(repository: activityRepository)
            
            let viewModel = StudentListViewModel(studentUseCases: studentUseCase, noteUseCases: noteUseCases, activityUseCases: activityUseCase)
            
            MainTabView(studentListViewModel: viewModel)
        }
        .modelContainer(container)
    }
}
