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
            let activityRepository = NoteRepositoryImpl(dataSource: noteDataSource)
            let activityUseCase = NoteUseCaseImpl(repository: activityRepository)
            
            let activityDataSource = ActivityDataSourceImpl(context: context)
            let toiletTrainingRepository = ActivityRepositoryImpl(activityDataSource: activityDataSource)
            let toiletTrainingUseCase = ActivityUseCaseImpl(repository: toiletTrainingRepository)
            
            let viewModel = StudentListViewModel(studentUseCases: studentUseCase, activityUseCases: activityUseCase, toiletTrainingUseCases: toiletTrainingUseCase)
            
            MainTabView(studentListViewModel: viewModel)
        }
        .modelContainer(container)
    }
}
