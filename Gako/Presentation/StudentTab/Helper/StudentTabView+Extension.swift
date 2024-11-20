//
//  StudentTabView+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension for StudentTabView that provides a filtered list of students based on a search query.
//  Usage: Use the filteredStudents property to dynamically filter students by nickname or full name in the StudentTabView.
//

import Foundation

extension StudentTabView {
    var filteredStudents: [Student] {
        if searchQuery.isEmpty {
            return studentViewModel.students
        } else {
            return studentViewModel.students.filter { student in
                student.nickname.localizedCaseInsensitiveContains(searchQuery) ||
                student.fullname.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}
