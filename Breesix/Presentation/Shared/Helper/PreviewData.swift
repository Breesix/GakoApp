//
//  PreviewData.swift
//  Breesix
//
//  Created by Rangga Biner on 13/11/24.
//
import SwiftUI
import SwiftData

struct PreviewHelper {
    
    /// Creates a ModelContainer for preview purposes
    static func createPreviewModelContainer() -> ModelContainer {
        do {
            let container = try ModelContainer(for: Student.self, Note.self, Activity.self, Summary.self)
            return container
        } catch {
            fatalError("Failed to create ModelContainer for preview: \(error.localizedDescription)")
        }
    }
    
    /// Creates all ViewModels for preview
    @MainActor static func createPreviewViewModels() -> (
        StudentViewModel,
        NoteViewModel,
        ActivityViewModel,
        SummaryViewModel,
        AppColor
    ) {
        let container = createPreviewModelContainer()
        let context = container.mainContext
        
        // Student ViewModel
        let studentDataSource = StudentDataSourceImpl(context: context)
        let studentRepository = StudentRepositoryImpl(dataSource: studentDataSource)
        let studentUseCase = StudentUseCaseImpl(repository: studentRepository)
        let studentViewModel = StudentViewModel(studentUseCases: studentUseCase)
        
        // Note ViewModel
        let noteDataSource = NoteDataSourceImpl(context: context)
        let noteRepository = NoteRepositoryImpl(dataSource: noteDataSource)
        let noteUseCases = NoteUseCaseImpl(repository: noteRepository)
        let noteViewModel = NoteViewModel(studentViewModel: studentViewModel, noteUseCases: noteUseCases)
        
        // Activity ViewModel
        let activityDataSource = ActivityDataSourceImpl(context: context)
        let activityRepository = ActivityRepositoryImpl(dataSource: activityDataSource)
        let activityUseCase = ActivityUseCaseImpl(repository: activityRepository)
        let activityViewModel = ActivityViewModel(studentViewModel: studentViewModel, activityUseCases: activityUseCase)
        
        // Summary ViewModel
        let summaryDataSource = SummaryDataSourceImpl(context: context)
        let summaryRepository = SummaryRepositoryImpl(dataSource: summaryDataSource)
        let summaryUseCase = SummaryUseCaseImpl(repository: summaryRepository)
        let summaryService = SummaryService(summaryUseCase: summaryUseCase)
        let summaryLlamaService = SummaryLlamaService(
            apiKey: "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",
            summaryUseCase: summaryUseCase
        )
        let summaryViewModel = SummaryViewModel(
            studentViewModel: studentViewModel,
            summaryUseCase: summaryUseCase,
            summaryService: summaryService,
            summaryLlamaService: summaryLlamaService
        )
        
        let appColor = AppColor()
        
        return (studentViewModel, noteViewModel, activityViewModel, summaryViewModel, appColor)
    }
    
    /// Creates a preview wrapper view
    struct PreviewWrapper<Content: View>: View {
        let content: Content
        @StateObject private var appColor = AppColor()
        @StateObject private var tabBarController = TabBarController() // Add this

        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            let viewModels = createPreviewViewModels()
            content
                .environmentObject(viewModels.0) // StudentViewModel
                .environmentObject(viewModels.1) // NoteViewModel
                .environmentObject(viewModels.2) // ActivityViewModel
                .environmentObject(viewModels.3) // SummaryViewModel
                .environmentObject(viewModels.4) // AppColor
                .environmentObject(tabBarController) // Add this
                .tint(appColor.tint)
                .accentColor(appColor.tint)
        }
    }
}

// Cara penggunaan di Preview:
#Preview {
    PreviewHelper.PreviewWrapper {
        StudentTabView(isAddingStudent: .constant(true))
    }
}

// Extension untuk PreviewProvider
extension PreviewProvider {
    static var previewStudentViewModel: StudentViewModel {
        PreviewHelper.createPreviewViewModels().0
    }
    
    static var previewNoteViewModel: NoteViewModel {
        PreviewHelper.createPreviewViewModels().1
    }
    
    static var previewActivityViewModel: ActivityViewModel {
        PreviewHelper.createPreviewViewModels().2
    }
    
    static var previewSummaryViewModel: SummaryViewModel {
        PreviewHelper.createPreviewViewModels().3
    }
    
    static var previewAppColor: AppColor {
        PreviewHelper.createPreviewViewModels().4
    }
}
