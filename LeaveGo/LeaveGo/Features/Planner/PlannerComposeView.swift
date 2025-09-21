//
//  PlannerComposeView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/15/25.
//

import SwiftUI
import PhotosUI

struct PlannerComposeView: View {
    let selectedPlaces: [PlaceDTO]
    
    @State var plannerTitle = ""
    @State var shouldProceed: Bool = false
    @State var selectedPlaceForDetails: PlaceDTO?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignToken.Spacing.xxxLarge) {
                    PlannerNameSection(value: $plannerTitle)
                    
                    ThumbnailSection()
                    
                    PlaceListSection(selectedPlaces: selectedPlaces)
                }
                .padding(.horizontal, DesignToken.Spacing.large)
            }
            .frame(maxHeight: .infinity)
            
            BottomActionButton(
                title: "여행 만들기",
                isEnabled: !plannerTitle.isEmpty
            ) {
                print("\(plannerTitle) 여행 생성: \(selectedPlaces.map { $0.title })")
            }
        }
        .navigationTitle("새로운 여행 만들기")
        .onAppear {
            print("\(selectedPlaces.map { $0.title })")
        }
    }
}

struct PlannerNameSection: View {
    @Binding var value: String
    
    var body: some View {
        CommonTextField(
            label: "제목 *",
            value: $value,
            prompt: "여행의 제목을 입력하세요"
        )
    }
}

struct ThumbnailSection: View {
    @State var photoItem: PhotosPickerItem?
    @State var selectedImage: UIImage?
    
    let imageWidth: CGFloat = 80
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignToken.Spacing.medium) {
            HStack {
                SectionHeader(title: "썸네일")
                
                Spacer()
                
                PhotosPicker(
                    selection: $photoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    SectionButtonLabel(title: "사진 가져오기")
                }
            }
            
            if let selectedImage {
                SelectedImageView(selectedImage: selectedImage, imageWidth: imageWidth)
            } else {
                PlaceholderImageView(width: imageWidth)
            }
        }
        .task(id: photoItem) {
            guard let photoItem = photoItem else { return }

            if let data = try? await photoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        }
    }
    
    private struct SelectedImageView: View {
        let selectedImage: UIImage
        let imageWidth: CGFloat
        
        var body: some View {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFill()
                .frame(width: imageWidth, height: imageWidth)
                .clipShape(RoundedRectangle(cornerRadius: DesignToken.Radius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignToken.Radius.medium)
                        .strokeBorder(.lgBorderProminent)
                )
        }
    }
}

struct PlaceListSection: View {
    @Environment(\.dismiss) var dismiss
    
    let selectedPlaces: [PlaceDTO]
    
    @State var selectedPlaceForDetails: PlaceDTO?
    
    var body: some View {
        VStack(spacing: DesignToken.Spacing.medium) {
            HStack {
                SectionHeader(title: "여행지 *")
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    SectionButtonLabel(title: "여행지 다시 선택하기")
                }
            }
            
            LazyVStack(spacing: DesignToken.Spacing.large) {
                ForEach(selectedPlaces) { place in
                    PlaceListRow(
                        place: place,
                        listMode: .draggable,
                        rowAction: nil) {
                            selectedPlaceForDetails = place
                        }
                        .sheet(item: $selectedPlaceForDetails) { place in
                            Text(place.title)
                                .presentationDetents([.fraction(0.4), .large])
                        }
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    PlannerComposeView(selectedPlaces: mockPlaceArray)
}
