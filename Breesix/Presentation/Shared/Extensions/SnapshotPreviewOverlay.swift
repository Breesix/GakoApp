//
//  SnapshotPreviewOverlay.swift
//  Breesix
//
//  Created by Kevin Fairuz on 12/11/24.
//
import SwiftUI

struct SnapshotPreviewOverlay: View {
    let images: [UIImage]
    @Binding var currentPageIndex: Int
    @Binding var showSnapshotPreview: Bool
    @Binding var toast: Toast?
    let shareToWhatsApp: ([UIImage]) -> Void
    let showShareSheet: ([UIImage]) -> Void
    
    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .transition(.opacity)
        
        VStack(spacing: 0) {

            HStack {
                Button(action: {
                    withAnimation {
                        showSnapshotPreview = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                Text("Preview (\(currentPageIndex + 1)/\(images.count))")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()

                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.clear)
                    .padding()
            }
            .background(Color.black.opacity(0.3))
            

            TabView(selection: $currentPageIndex) {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                        .padding(.horizontal)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            

            HStack(spacing: 8) {
                ForEach(0..<images.count, id: \.self) { index in
                    Circle()
                        .fill(currentPageIndex == index ? Color.accent : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 16)
            

            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                
                HStack(spacing: 20) {
              
                    ShareButton(
                        title: "WhatsApp",
                        icon: "square.and.arrow.up",
                        color: .green
                    ) {
                        shareToWhatsApp(images)
                    }
                    
     
                    ShareButton(
                        title: "Save All",
                        icon: "square.and.arrow.down",
                        color: .blue
                    ) {
                        Task {
                            do {
                                for image in images {
                                    try await ImageSaver.shared.saveImage(image)
                                }
                                toast = Toast(
                                    style: .success,
                                    message: "Semua halaman berhasil disimpan",
                                    duration: 2,
                                    width: 280
                                )
                                withAnimation {
                                    showSnapshotPreview = false
                                }
                            } catch {
                                toast = Toast(
                                    style: .error,
                                    message: "Gagal menyimpan gambar",
                                    duration: 2,
                                    width: 280
                                )
                            }
                        }
                    }

                    ShareButton(
                        title: "Share All",
                        icon: "square.and.arrow.up",
                        color: .orange
                    ) {
                        showShareSheet(images)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16, corners: [.topLeft, .topRight])
        }
        .transition(.move(edge: .bottom))
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
