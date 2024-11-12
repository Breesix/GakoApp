struct SnapshotPreviewOverlay: View {
    let images: [UIImage]
    @Binding var currentPageIndex: Int
    @Binding var showSnapshotPreview: Bool
    @Binding var toast: Toast?
    let shareToWhatsApp: (UIImage) -> Void
    let showShareSheet: (UIImage) -> Void
    
    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
                withAnimation {
                    showSnapshotPreview = false
                }
            }
        
        VStack(spacing: 0) {
            // Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<images.count, id: \.self) { index in
                    Circle()
                        .fill(currentPageIndex == index ? Color.blue : Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top)
            
            // Preview Images with TabView
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
            
            Spacer()
            
            // Bottom Sheet dengan tombol share
            VStack(spacing: 16) {
                // Drag Indicator
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                
                // Share Buttons
                HStack(spacing: 20) {
                    // WhatsApp Button
                    ShareButton(
                        title: "WhatsApp",
                        icon: "square.and.arrow.up",
                        color: .green
                    ) {
                        shareToWhatsApp(images[currentPageIndex])
                    }
                    
                    // Save Button
                    ShareButton(
                        title: "Save",
                        icon: "square.and.arrow.down",
                        color: .blue
                    ) {
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: images[currentPageIndex])
                        toast = Toast(
                            style: .success,
                            message: "Image saved to photo library",
                            duration: 2,
                            width: 280
                        )
                    }
                    
                    // Share Button
                    ShareButton(
                        title: "Share",
                        icon: "square.and.arrow.up",
                        color: .orange
                    ) {
                        showShareSheet(images[currentPageIndex])
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