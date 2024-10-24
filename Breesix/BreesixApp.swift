//
//  BreesixApp.swift
//  Breesix
//
//  Created by Rangga Biner on 19/09/24.
//

import SwiftUI
import SwiftData
import Speech

@main
struct BreesixApp: App {
    let container: ModelContainer
    @State private var showTabBar: Bool = true
    init() {
        do {
            container = try ModelContainer(for: Student.self, Note.self, Activity.self)
            requestSpeechAuthorization()
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
            
            let noteRepository = NoteRepositoryImpl(context: context)
            let noteUseCases = NoteUseCaseImpl(repository: noteRepository)
            
            let activityRepository = ActivityRepositoryImpl(context: context)
            let activityUseCase = ActivityUseCaseImpl(repository: activityRepository)
            
            let summaryRepository = SummaryRepositoryImpl(context: context)
            let summaryUseCase = SummaryUseCaseImpl(repository: summaryRepository)
            
            let summaryService = SummaryService(
                apiToken: "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",
                summaryUseCase: summaryUseCase
            )


            let viewModel = StudentListViewModel(studentUseCases: studentUseCase, noteUseCases: noteUseCases, activityUseCases: activityUseCase, summaryUseCase: summaryUseCase, summaryService: summaryService)
            MainTabView(studentListViewModel: viewModel )
        }
        .modelContainer(container)
    }
}

func requestSpeechAuthorization() {
    SFSpeechRecognizer.requestAuthorization { authStatus in
        switch authStatus {
        case .authorized:
            print("Speech recognition authorized")
        case .denied:
            print("Speech recognition denied")
        case .restricted:
            print("Speech recognition restricted")
        case .notDetermined:
            print("Speech recognition not determined")
        @unknown default:
            print("Unknown status")
        }
    }
}
