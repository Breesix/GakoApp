//
//  StudentRowCard.swift
//  Breesix
//
//  Created by Rangga Biner on 27/09/24.
//

import SwiftUI

struct StudentRowCard: View {
    let student: Student
        
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 30))
                VStack (alignment: .leading){
                    Text(student.nickname)
                    Text(student.name)
                }
                Spacer()
            }
            Divider()
            HStack {
                Spacer()
                HStack{
                    Button(action: {
                        print("dokum")
                    }, label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Dokumentasi")
                        }
                        
                        .background(Color.gray.opacity(0.1))
                        
                    })
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.black)
        .cornerRadius(10)

    }
}

#Preview {
    StudentRowCard(student: Student(name: "rangga hadi putra", nickname: "rangga"))
}
