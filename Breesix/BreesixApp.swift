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
            fatalError("Failed to create ModelContainer for Student and Note: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            let context = container.mainContext
            
            let studentDataSource = StudentDataSourceImpl(context: context)
            let studentRepository = StudentRepositoryImpl(dataSource: studentDataSource)
            let studentUseCase = StudentUseCase(repository: studentRepository)
            
            let noteRepository = NoteRepositoryImpl(context: context)
            let noteUseCase = NoteUseCase(repository: noteRepository)
            
            let viewModel = StudentListViewModel(studentUseCases: studentUseCase, noteUseCases: noteUseCase)
            
            StudentListView(viewModel: viewModel)
        }
        .modelContainer(container)
    }
}
