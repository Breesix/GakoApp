//
//  ManageStudentView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI
import PhotosUI

struct ManageStudentView: View {
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
    @State private var isDuplicateNickname = false
    @State private var currentImage: UIImage? // Add this state variable
    
    let onSave: (Student) async -> Void
    let onUpdate: (Student) async -> Void
    let onImageChange: (UIImage?) -> Void
    let checkNickname: (String, UUID?) -> Bool
    let compressedImageData: Data?
    let newStudentImage: UIImage?
    
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
    
    init(mode: Mode,
         compressedImageData: Data?,
         newStudentImage: UIImage?,
         onSave: @escaping (Student) async -> Void,
         onUpdate: @escaping (Student) async -> Void,
         onImageChange: @escaping (UIImage?) -> Void,
         checkNickname: @escaping (String, UUID?) -> Bool) {
        self.mode = mode
        self.onSave = onSave
        self.onUpdate = onUpdate
        self.onImageChange = onImageChange
        self.checkNickname = checkNickname
        self.compressedImageData = compressedImageData
        self.newStudentImage = newStudentImage
        
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
    
    private func checkDuplicateNickname(_ nickname: String) -> Bool {
        switch mode {
        case .add:
            return checkNickname(nickname, nil)
        case .edit(let currentStudent):
            return checkNickname(nickname, currentStudent.id)
        }
    }
    
    private func saveStudent() {
        Task {
            if (fullname.isEmpty || nickname.isEmpty) {
                showAlert = true
                return
            }
            
            if isDuplicateNickname {
                showAlert = true
                return
            }
            
            let imageDataToSave = compressedImageData ?? currentImage?.jpegData(compressionQuality: 0.7)
            
            switch mode {
            case .add:
                let newStudent = Student(
                    fullname: fullname,
                    nickname: nickname,
                    imageData: imageDataToSave
                )
                await onSave(newStudent)
            case .edit(let student):
                student.fullname = fullname
                student.nickname = nickname
                student.imageData = imageDataToSave ?? student.imageData
                await onUpdate(student)
            }
            
            selectedImageData = nil
            currentImage = nil
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    var displayImage: UIImage? {
        if let image = currentImage {
            return image
        } else if let data = compressedImageData, let image = UIImage(data: data) {
            return image
        } else if case .edit(let student) = mode, let imageData = student.imageData, let image = UIImage(data: imageData) {
            return image
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 12) {
                VStack(alignment: .center, spacing: 8) {
                    if let image = displayImage {
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
                                .onChange(of: nickname) {
                                    isDuplicateNickname = checkDuplicateNickname(nickname)
                                }
                        }
                        .background(.cardFieldBG)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isDuplicateNickname ? Color.red : .monochrome50, lineWidth: isDuplicateNickname ? 1 : 0.5)
                        )
                        
                        if isDuplicateNickname {
                            Text("Nama panggilan sudah digunakan")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
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
            ActionSheet(
                title: Text("Choose Image Source"),
                buttons: [
                    .default(Text("Camera")) {
                        sourceType = .camera
                        showingImagePicker = true
                    },
                    .default(Text("Photo Library")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: Binding(
                get: { currentImage },
                set: { newImage in
                    currentImage = newImage
                    onImageChange(newImage)
                }
            ), sourceType: sourceType)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Peringatan"),
                message: Text(isDuplicateNickname ? "Nama panggilan sudah digunakan. Mohon gunakan nama panggilan lain." : "Pastikan nama lengkap dan nama panggilan sudah terisi"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}


#Preview {
    ManageStudentView(
        mode: .add,
        compressedImageData: nil,
        newStudentImage: nil,
        onSave: { _ in print("saved")},
        onUpdate: { _ in print("updated") },
        onImageChange: { _ in print("image changed") },
        checkNickname: { _, _ in false}
    )
}
