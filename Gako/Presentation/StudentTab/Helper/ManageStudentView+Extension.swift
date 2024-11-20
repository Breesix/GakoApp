//
//  ManageStudentView+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides helper methods and logic for ManageStudentView
//  Usage: Contains functionality for managing student data, including saving and checking for duplicate nicknames
//

import Foundation
import UIKit

extension ManageStudentView {
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
    
    func checkDuplicateNickname(_ nickname: String) -> Bool {
        switch mode {
        case .add:
            return checkNickname(nickname, nil)
        case .edit(let currentStudent):
            return checkNickname(nickname, currentStudent.id)
        }
    }
    
    func saveStudent() {
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

}
