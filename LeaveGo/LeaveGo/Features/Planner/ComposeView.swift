//
//  ComposeView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/15/25.
//

import SwiftUI
import PhotosUI

extension PlannerView {
    struct ComposeView: View {
        @Environment(PlannerViewModel.self) var plannerViewModel
        
        let selectedPlaces: [PlaceDTO]
        
        @State var shouldProceed: Bool = false
        @State var selectedPlace: PlaceDTO?
        
        var body: some View {
            ZStack(alignment: .bottom) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: DesignToken.Spacing.xxxLarge) {
                        PlannerNameSection()
                        
                        ThumbnailSection()
                        
                        PlaceListSection(selectedPlaces: selectedPlaces)
                    }
                    .padding(.horizontal, DesignToken.Spacing.large)
                }
                .frame(maxHeight: .infinity)
                
                BottomActionButton(
                    title: "여행 만들기",
                    isEnabled: plannerViewModel.plannerTitle != nil
                ) {
                    Task {
                        await plannerViewModel.savePlanner(placeList: selectedPlaces)
                    }
                }
            }
            .navigationTitle("새로운 여행 만들기")
        }
    }
    
    struct PlannerNameSection: View {
        @Environment(PlannerViewModel.self) var plannerViewModel
        
        var body: some View {
            CommonTextField(
                label: "제목 *",
                value: plannerViewModel.titleBinding,
                prompt: "여행의 제목을 입력하세요"
            )
        }
    }
    
    struct ThumbnailSection: View {
        @Environment(PlannerViewModel.self) var plannerViewModel
        
        @State var photoPickerItem: PhotosPickerItem?
        
        let imageWidth: CGFloat = 80
        
        var body: some View {
            VStack(alignment: .leading, spacing: DesignToken.Spacing.medium) {
                HStack {
                    SectionHeader(title: "썸네일")
                    
                    Spacer()
                    
                    PhotosPicker(
                        selection: $photoPickerItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        SectionButtonLabel(title: "사진 가져오기")
                    }
                }
                
                if let selectedImage = plannerViewModel.selectedImage {
                    SelectedImageView(selectedImage: selectedImage, imageWidth: imageWidth)
                } else {
                    PlaceholderImageView(width: imageWidth)
                }
            }
            .task(id: photoPickerItem) {
                guard let photoPickerItem else { return }
                
                if let data = try? await photoPickerItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    guard let thumbnail = await image
                        .byPreparingThumbnail(ofSize: CGSize(width: 300, height: 300)) else { return }
                    plannerViewModel.selectedImage = thumbnail
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
        
        @State var selectedPlace: PlaceDTO?
        
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
                                selectedPlace = place
                            }
                    }
                }
                .padding(.bottom, DesignToken.Layout.bottomActionButtonHeight)
                .sheet(item: $selectedPlace) { place in
                    PlaceDetailSheetView(place: place, buttonTitle: "경로 찾기")
                        .presentationDetents([.fraction(0.4), .large])
                }
                
                Spacer() 
            }
        }
    }
}

#Preview {
    let previewPlace = PlaceDTO(
        addr1: Optional("대구광역시 동구 각산동"),
        addr2: Optional("134"),
        areaCode: Optional("4"),
        cat1: Optional("A01"),
        cat2: Optional("A0101"),
        cat3: Optional("A01010500"),
        id: "2667909",
        contentTypeID: "12",
        dist: nil,
        bigThumbnailImage: Optional(""),
        thumbnailImage: Optional(""),
        mapX: Optional("128.7199264348"),
        mapY: Optional("35.8799433837"),
        tel: Optional(""),
        title: "나불지 생태공원"
    )
    
    PlannerView.ComposeView(selectedPlaces: [previewPlace])
        .environment(PlannerViewModel())
}
