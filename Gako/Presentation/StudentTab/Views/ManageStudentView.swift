//
//  ManageStudentView.swift
//  Gako
//
//  Created by Rangga Biner on 03/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A view for managing the addition and editing of student information
//  Usage: Use this view to input or modify student details, including fullname, nickname, and profile image
//

import SwiftUI
import PhotosUI

struct ManageStudentView: View {
    // MARK: - Properties
    @Environment(\.presentationMode) var presentationMode
    @State var fullname = ""
    @State var nickname = ""
    @State var selectedItem: PhotosPickerItem?
    @State var selectedImageData: Data?
    @State var isShowingCamera = false
    @State var capturedImage: UIImage?
    @State var showingImagePicker = false
    @State var showingSourceTypeMenu = false
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var showAlert = false
    @State var isDuplicateNickname = false
    @State var currentImage: UIImage?
    let onSave: (Student) async -> Void
    let onUpdate: (Student) async -> Void
    let onImageChange: (UIImage?) -> Void
    let checkNickname: (String, UUID?) -> Bool
    let compressedImageData: Data?
    let newStudentImage: UIImage?
    let mode: Mode
    
    // MARK: - Initialization
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
    
    // MARK: - Body
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
                        onImageChange(nil)
                        currentImage = nil
                        selectedImageData = nil
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
        .onDisappear {
            onImageChange(nil)
            currentImage = nil
            selectedImageData = nil
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


// MARK: - Preview
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
