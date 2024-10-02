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
            container = try ModelContainer(for: Student.self, Activity.self)
        } catch {
            fatalError("Failed to create ModelContainer for Student and Note: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            let context = container.mainContext
            
            let studentDataSource = StudentDataSourceImpl(context: context)
            let studentRepository = StudentRepositoryImpl(dataSource: studentDataSource)
            let studentUseCase = StudentUseCase(repository: studentRepository)
            
            let noteRepository = GeneralActivityRepositoryImpl(context: context)
            let noteUseCase = GeneralActivityUseCase(repository: noteRepository)
            
            let viewModel = StudentListViewModel(studentUseCases: studentUseCase, generalActivityUseCases: noteUseCase)
            
            MainTabView(studentListViewModel: viewModel)
        }
        .modelContainer(container)
    }
}
