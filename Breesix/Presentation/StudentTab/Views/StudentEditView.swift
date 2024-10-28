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
                        Text("Tambah Foto")
                    }
                }
                .padding(.top, 34.5)
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nama Lengkap")
                            .foregroundStyle(.labelPrimaryBlack)
                            .font(.callout)
                            .fontWeight(.semibold)
                        ZStack(alignment: .leading) {
                            if fullname.isEmpty {
                                Text("Nama Lengkap Murid")
                                    .foregroundStyle(.labelTertiary)
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 9)
                            }
                            TextField("", text: $fullname)
                                .foregroundStyle(.labelPrimaryBlack)
                                .font(.body)
                                .fontWeight(.regular)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 9)
                        }
                        .background(.cardFieldBG)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.monochrome50, lineWidth: 0.5)
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nama Panggilan")
                            .foregroundStyle(.labelPrimaryBlack)
                            .font(.callout)
                            .fontWeight(.semibold)
                        ZStack(alignment: .leading) {
                            if nickname.isEmpty {
                                Text("Nama Panggilan Murid")
                                    .foregroundStyle(.labelTertiary)
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 9)
                            }
                            
                            TextField("", text: $nickname)
                                .foregroundStyle(.labelPrimaryBlack)
                                .font(.body)
                                .fontWeight(.regular)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 9)
                        }
                        .background(.cardFieldBG)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.monochrome50, lineWidth: 0.5)
                        )
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .background(.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(mode == .add ? "Tambah Murid" : "Edit Murid")
                        .foregroundStyle(.buttonPrimaryLabel)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text("Kembali")
                        }
                        .font(.body)
                        .fontWeight(.medium)
                    }
                    .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveStudent()
                    }) {
                        Text("Simpan")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 27)
                }
            }
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Peringatan"),
                message: Text("Pastikan nama lengkap dan nama panggilan sudah terisi"),
                dismissButton: .default(Text("OK"))
            )
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
