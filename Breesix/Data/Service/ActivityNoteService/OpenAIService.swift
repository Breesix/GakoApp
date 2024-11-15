//
//  OpenAIService.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation
import OpenAI
import SwiftData

class OpenAIService {
    private let openAI: OpenAI
    
    init(apiToken: String) {
        self.openAI = OpenAI(apiToken: APIConfig.openAIToken)
    }
    
    func processReflection(
        reflection: String,
        students: [Student],
        selectedStudents: Set<Student>,
        activities: [String]
    ) async throws -> String {
        // Create student info string including attendance status
        let studentInfo = students.map { student in
            let isPresent = selectedStudents.contains(student)
            return "\(student.fullname) (\(student.nickname)) - \(isPresent ? "Hadir" : "Tidak Hadir")"
        }.joined(separator: ", ")
        
        // Create activities string
        let activitiesInfo = activities.isEmpty ?
            "Tidak ada aktivitas yang tercatat" :
            activities.joined(separator: ", ")

        if students.isEmpty {
            throw ProcessingError.noStudentData
        }
        
        let userInput = """
        INPUT USER:
        Input User yang harus anda analisis adalah:

        Data Kehadiran Murid: \(studentInfo)
        
        Aktivitas Hari Ini: \(activitiesInfo)

        Curhatan Guru: \(reflection)
        """

        let fullPrompt = BotPrompts.reflectionPrompt + "\n\n" + userInput
        print(fullPrompt)
        let query = ChatQuery(messages: [.init(role: .user, content: fullPrompt)!], model: .gpt4_o_mini)
        
        let result = try await openAI.chats(query: query)
        
        guard let csvString = result.choices.first?.message.content?.string else {
            throw ProcessingError.noContent
        }
        
        if csvString.contains("Tidak ada informasi") && !csvString.contains(",") {
            throw ProcessingError.insufficientInformation
        }
        
        return csvString
    }
}

class ReflectionCSVParser {
    static func parseActivitiesAndNotes(csvString: String, students: [Student], createdAt: Date) -> ([UnsavedActivity], [UnsavedNote]) {
        let rows = csvString.components(separatedBy: .newlines)
        var unsavedActivities: [UnsavedActivity] = []
        var unsavedNotes: [UnsavedNote] = []
        
        print("Total rows in CSV: \(rows.count)")
        print("Available students: \(students.map { "\($0.fullname) (\($0.nickname))" })")
        
        for (index, row) in rows.dropFirst().enumerated() where !row.isEmpty {
            print("Processing row \(index + 1): \(row)")
            
            let columns = parseCSVRow(row)
            if columns.count >= 4 {
                let fullName = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let nickname = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let activitiesString = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let curhatan = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                
                print("Searching for student: \(fullName) (\(nickname))")
                if let student = findMatchingStudent(fullName: fullName, nickname: nickname, in: students) {
                    let activities = activitiesString.components(separatedBy: "|")
                    for activity in activities {
                        let parts = activity.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "(")
                        if parts.count == 2 {
                            let activityName = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let statusString = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ")", with: "")
                                .lowercased()
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            var status: Status
                            switch statusString {
                            case "true":
                                status = .mandiri
                            case "false":
                                status = .dibimbing
                            case "null", "nil", "":
                                status = .tidakMelakukan
                            default:
                                status = .tidakMelakukan
                            }
                            
                            if curhatan.contains("Tidak ada informasi aktivitas") {
                                status = .tidakMelakukan
                            }
                            
                            let unsavedActivity = UnsavedActivity(
                                activity: activityName,
                                createdAt: createdAt,
                                status: status,
                                studentId: student.id
                            )
                            unsavedActivities.append(unsavedActivity)
                        }
                    }
                    
                    let unsavedNote = UnsavedNote(
                        note: curhatan,
                        createdAt: createdAt,
                        studentId: student.id
                    )
                    unsavedNotes.append(unsavedNote)
                }
            }
        }
        
        print("Total activities created: \(unsavedActivities.count)")
        print("Total notes created: \(unsavedNotes.count)")
        return (unsavedActivities, unsavedNotes)
    }
    
    private static func parseCSVRow(_ row: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        
        for character in row {
            if character == "\"" {
                insideQuotes.toggle()
            } else if character == "," && !insideQuotes {
                columns.append(currentColumn)
                currentColumn = ""
            } else {
                currentColumn.append(character)
            }
        }
        
        columns.append(currentColumn)
        return columns
    }
    
    private static func findMatchingStudent(fullName: String, nickname: String, in students: [Student]) -> Student? {
        let normalizedFullName = fullName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedNickname = nickname.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return students.first { student in
            let studentFullName = student.fullname.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let studentNickname = student.nickname.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            return studentFullName == normalizedFullName || studentNickname == normalizedNickname
        }
    }
}
