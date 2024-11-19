//
//  SnapshotPreviewOverlay.swift
//  Gako
//
//  Created by Kevin Fairuz on 12/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A preview for snapshot
//  Usage: Use this view for display preview the snapshot
//

import SwiftUI

struct SnapshotPreview: View {
    let images: [UIImage]
    @Binding var currentPageIndex: Int
    @Binding var showSnapshotPreview: Bool
    @Binding var toast: Toast?
    let shareToWhatsApp: ([UIImage]) -> Void
    let showShareSheet: ([UIImage]) -> Void
    
    var maxHeightMultiplier: CGFloat = UIConstants.SnapshotPreview.maxHeightMultiplier
    var bottomSheetCornerRadius: CGFloat = UIConstants.SnapshotPreview.bottomSheetCornerRadius
    var dragIndicatorHeight: CGFloat = UIConstants.SnapshotPreview.dragIndicatorHeight
    var dragIndicatorWidth: CGFloat = UIConstants.SnapshotPreview.dragIndicatorWidth
    var buttonSpacing: CGFloat = UIConstants.SnapshotPreview.buttonSpacing
    var horizontalPadding: CGFloat = UIConstants.SnapshotPreview.horizontalPadding
    var bottomPadding: CGFloat = UIConstants.SnapshotPreview.bottomPadding
    var topPadding: CGFloat = UIConstants.SnapshotPreview.topPadding
    var pageIndicatorSpacing: CGFloat = UIConstants.SnapshotPreview.pageIndicatorSpacing
    var pageIndicatorBottomPadding: CGFloat = UIConstants.SnapshotPreview.pageIndicatorBottomPadding
    var pageIndicatorDotSize: CGFloat = UIConstants.SnapshotPreview.pageIndicatorDotSize
    var overlayColor: Color = UIConstants.SnapshotPreview.overlayColor
    var headerBackgroundColor: Color = UIConstants.SnapshotPreview.headerBackgroundColor
    var dragIndicatorColor: Color = UIConstants.SnapshotPreview.dragIndicatorColor
    var bottomSheetColor: Color = UIConstants.SnapshotPreview.bottomSheetColor
    var whatsAppButtonColor: Color = UIConstants.SnapshotPreview.whatsAppButtonColor
    var saveButtonColor: Color = UIConstants.SnapshotPreview.saveButtonColor
    var shareButtonColor: Color = UIConstants.SnapshotPreview.shareButtonColor
    var saveSuccessMessage: String = UIConstants.SnapshotPreview.saveSuccessMessage
    var saveErrorMessage: String = UIConstants.SnapshotPreview.saveErrorMessage
    var shareTitle: String = UIConstants.SnapshotPreview.shareTitle
    var shareIcon: String = UIConstants.SnapshotPreview.shareIcon
    var whatsAppTitle: String = UIConstants.SnapshotPreview.whatsAppTitle
    var whatsAppIcon: String = UIConstants.SnapshotPreview.whatsAppIcon
    var saveTitle: String = UIConstants.SnapshotPreview.saveTitle
    var saveIcon: String = UIConstants.SnapshotPreview.saveIcon
    var durationToast: CGFloat = UIConstants.SnapshotPreview.durationToast
    var dragIndicatorCornerRadius: CGFloat = UIConstants.SnapshotPreview.dragIndicatorCornerRadius
    var dragIndicatorSpacing: CGFloat = UIConstants.SnapshotPreview.dragIndicatorSpacing
    var xmarkSymbol: String = UIConstants.SnapshotPreview.xmarkSymbol
    var activeDotColor: Color = UIConstants.SnapshotPreview.activeDotColor
    var inactiveDotColor: Color = UIConstants.SnapshotPreview.inactiveDotColor
    
    var body: some View {
        overlayColor
            .ignoresSafeArea()
            .transition(.opacity)
        
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        showSnapshotPreview = false
                    }
                }) {
                    Image(systemName: xmarkSymbol)
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
                Text("Preview (\(currentPageIndex + 1)/\(images.count))")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: xmarkSymbol)
                    .font(.title3)
                    .foregroundColor(.clear)
                    .padding()
            }
            .background(headerBackgroundColor)
            
            TabView(selection: $currentPageIndex) {
                ForEach(images.indices, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: UIScreen.main.bounds.height * maxHeightMultiplier)
                        .padding(.horizontal)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            HStack(spacing: pageIndicatorSpacing) {
                ForEach(0..<images.count, id: \.self) { index in
                    Circle()
                        .fill(currentPageIndex == index ? activeDotColor : inactiveDotColor)
                        .frame(width: pageIndicatorDotSize, height: pageIndicatorDotSize)
                }
            }
            .padding(.bottom, pageIndicatorBottomPadding)

            VStack(spacing: dragIndicatorSpacing) {
                RoundedRectangle(cornerRadius: dragIndicatorCornerRadius)
                    .fill(dragIndicatorColor)
                    .frame(width: dragIndicatorWidth, height: dragIndicatorHeight)
                    .padding(.top, topPadding)
                
                HStack(spacing: buttonSpacing) {
                    ShareButton(
                        title: whatsAppTitle,
                        icon: whatsAppIcon,
                        color: whatsAppButtonColor
                    ) {
                        shareToWhatsApp(images)
                    }
                    ShareButton(
                        title: shareTitle,
                        icon: shareIcon,
                        color: saveButtonColor
                    ) {
                        Task {
                            do {
                                for image in images {
                                    try await ImageSaver.shared.saveImage(image)
                                }
                                toast = Toast(
                                    style: .success,
                                    message: saveSuccessMessage,
                                    duration: durationToast
                                )
                                withAnimation {
                                    showSnapshotPreview = false
                                }
                            } catch {
                                toast = Toast(
                                    style: .error,
                                    message: saveErrorMessage,
                                    duration: durationToast,
                                    width: .infinity
                                )
                            }
                        }
                    }

                    ShareButton(
                        title: saveTitle,
                        icon: saveIcon,
                        color: shareButtonColor
                    ) {
                        showShareSheet(images)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, bottomPadding)
            }
            .frame(maxWidth: .infinity)
            .background(bottomSheetColor)
            .cornerRadius(bottomSheetCornerRadius, corners: [.topLeft, .topRight])
        }
        .transition(.move(edge: .bottom))
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    SnapshotPreview(
        images: [
            UIImage(systemName: "photo.fill") ?? UIImage(),
            UIImage(systemName: "photo.fill.on.rectangle.fill") ?? UIImage(),
            UIImage(systemName: "photo.stack.fill") ?? UIImage()
        ],
        currentPageIndex: .constant(0),
        showSnapshotPreview: .constant(true),
        toast: .constant(nil),
        shareToWhatsApp: { _ in },
        showShareSheet: { _ in }
    )
}
