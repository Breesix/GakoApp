import SwiftUI
import PhotosUI
struct StudentEditView: View {
    @ObservedObject var viewModel: StudentTabViewModel
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
    
    @State private var showAlert = false
    
    
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
    
    init(viewModel: StudentTabViewModel, mode: Mode) {
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
            VStack(alignment: .center, spacing: 12) {
                VStack(alignment: .center, spacing: 8) {
                    if let imageData = viewModel.compressedImageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else if case .edit(let student) = mode, let imageData = student.imageData,
                              let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                    Button(action: {
                        showingSourceTypeMenu = true
                    }) {
                        VStack {
                            Text("Pilih Foto")
                        }
                    }
                }
                .padding(.top, 24)
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nama Lengkap")
                            .font(.callout)
                            .fontWeight(.semibold)
                        TextField("Nama Lengkap Murid", text: $fullname)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nama Panggilan")
                            .font(.callout)
                            .fontWeight(.semibold)
                        TextField("Nama Panggilan Murid", text: $nickname)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .navigationTitle(mode == .add ? "Tambah Murid" : "Edit Murid")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveStudent()
            }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text("Please fill in all fields"), dismissButton: .default(Text("OK")))
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
    }
    
    private func saveStudent() {
        Task {
            if (fullname == "" || nickname == "") {
                showAlert = true
                return
            }
            switch mode {
            case .add:
                let newStudent = Student(
                    fullname: fullname,
                    nickname: nickname,
                    imageData: viewModel.compressedImageData
                )
                await viewModel.addStudent(newStudent)
                
            case .edit(let student):
                student.fullname = fullname
                student.nickname = nickname
                student.imageData = viewModel.compressedImageData ?? student.imageData
                await viewModel.updateStudent(student)
            }
            selectedImageData = nil
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
