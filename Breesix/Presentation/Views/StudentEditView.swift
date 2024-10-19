//
//  StudentEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI
import PhotosUI

struct StudentEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var fullname = ""
    @State private var nickname = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isShowingCamera = false
    @State private var capturedImage: UIImage?
    
    @State private var showingImagePicker = false
    @State private var showingSourceTypeMenu = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    
    enum Mode: Equatable {
        case add
        case edit(Student)
        
        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.add, .add):
                return true
            case let (.edit(student1), .edit(student2)):
                return student1.id == student2.id
            default:
                return false
            }
        }
    }
    
    let mode: Mode
    
    init(viewModel: StudentListViewModel, mode: Mode) {
        self.viewModel = viewModel
        self.mode = mode
        
        switch mode {
        case .add:
            _fullname = State(initialValue: "")
            _nickname = State(initialValue: "")
        case .edit(let student):
            _fullname = State(initialValue: student.fullname)
            _nickname = State(initialValue: student.nickname)
            _selectedImageData = State(initialValue: student.imageData)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Student Information")) {
                    TextField("Nama Panggilan", text: $nickname)
                    TextField("Nama Lengkap", text: $fullname)
                }
                
                Button(action: {
                    showingSourceTypeMenu = true
                }) {
                    HStack {
                        Text("Select Profile Picture")
                        Spacer()
                        if let imageData = viewModel.compressedImageData, let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else if case .edit(let student) = mode, let imageData = student.imageData,
                                  let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                //                Section(header: Text("Student Image")) {
                //                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                //                        Image(uiImage: uiImage)
                //                            .resizable()
                //                            .scaledToFit()
                //                            .frame(height: 200)
                //                    }
                //
                //
                //                    PhotosPicker(selection: $selectedItem, matching: .images) {
                //                        Text("Select Image")
                //                    }
                //
                //                    Button("Take Photo") {
                //                        isShowingCamera = true
                //                    }
                //                }
            }
            .navigationTitle(mode == .add ? "Tambah Murid" : "Edit Murid")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveStudent()
            })
        }
        .actionSheet(isPresented: $showingSourceTypeMenu) {
            ActionSheet(title: Text("Choose Image Source"), buttons: [
                .default(Text("Camera")) {
                    sourceType = .camera
                    showingImagePicker = true
                },
                .default(Text("Photo Library")) {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $viewModel.newStudentImage, sourceType: sourceType)
        }
        //        .onChange(of: selectedItem) { newItem in
        //            Task {
        //                if let data = try? await newItem?.loadTransferable(type: Data.self) {
        //                    // Compress image data from photo library
        //                    if let image = UIImage(data: data) {
        //                        selectedImageData = image.jpegData(compressionQuality: 0.8)
        //                    } else {
        //                        selectedImageData = data
        //                    }
        //                }
        //            }
        //        }
        //        .sheet(isPresented: $isShowingCamera) {
        //            CameraView(capturedImage: $capturedImage, isShowingCamera: $isShowingCamera)
        //        }
        //        .onChange(of: capturedImage) { newImage in
        //            if let newImage = newImage {
        //                // Camera image is already being compressed
        //                selectedImageData = newImage.jpegData(compressionQuality: 0.8)
        //            }
        //        }
    }
    
    private func saveStudent() {
        Task {
            switch mode {
            case .add:
                let newStudent = Student(
                    fullname: fullname,
                    nickname: nickname,
                    imageData: viewModel.compressedImageData // Use compressed image data
                )
                await viewModel.addStudent(newStudent)
                
            case .edit(let student):
                student.fullname = fullname
                student.nickname = nickname
                student.imageData = viewModel.compressedImageData ?? student.imageData
                await viewModel.updateStudent(student)
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var isShowingCamera: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.isShowingCamera = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShowingCamera = false
        }
    }
}
