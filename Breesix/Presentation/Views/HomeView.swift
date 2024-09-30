//
//  HomeView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var studentListViewModel: StudentListViewModel
    @State private var isShowingReflectionSheet = false
    @State private var isShowingPreview = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Anda belum curhat terkait kegiatan umum dan toilet training yang dilakukan oleh murid-murid")
                    Button(action: {
                        isShowingReflectionSheet = true
                    }) {
                        Text("Curhat Manual")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Curhat")
        }
        .sheet(isPresented: $isShowingReflectionSheet) {
            ReflectionInputView(viewModel: studentListViewModel, isShowingPreview: $isShowingPreview)
        }
        .sheet(isPresented: $isShowingPreview) {
            ReflectionPreviewView(viewModel: studentListViewModel)
        }
    }
}


