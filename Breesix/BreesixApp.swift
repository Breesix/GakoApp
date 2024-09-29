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
            container = try ModelContainer(for: Student.self)
        } catch {
            fatalError("Failed to create ModelContainer for  Note: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            let context = container.mainContext
            let dataSource = StudentDataSourceImpl(context: context)
            let repository = StudentRepositoryImpl(dataSource: dataSource)
            let useCases = StudentUseCase(repository: repository)
            let viewModel = StudentListViewModel(useCases: useCases)
            
            StudentListView(viewModel: viewModel)
        }
        .modelContainer(container)
    }
}
