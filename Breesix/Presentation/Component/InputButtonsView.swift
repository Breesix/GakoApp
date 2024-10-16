////
////  InputButtonsView.swift
////  Breesix
////
////  Created by Kevin Fairuz on 15/10/24.
////
//
//
//import SwiftUI
//
//struct InputButtonsView: View {
//    @Binding var selectedInputType: InputType
//    @State var isFilledToday: Bool // Passed from HomeView
//    
//    var body: some View {
//        
//        HStack(alignment: .center) {
//
//                        
//            NavigationLink(destination: TextInputView()) {
//                InputTypeButton(title: "Manual", action: {})
//            }
//        }
//    }
//}
//
//struct InputTypeButton: View {
//    let title: String
//    let action: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.headline)
//                .padding()
//           
//                Text("CURHAT DONG MAH")
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            
//        }
//        .padding()
//        .background(Color(red: 0.92, green: 0.96, blue: 0.96))
//        .cornerRadius(8)
//    }
//}
