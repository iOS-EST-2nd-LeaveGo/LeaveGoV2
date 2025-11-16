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
        
        var planner: PlannerDTO? = nil
        
        private var isNewPlanner: Bool {
            return planner == nil
        }
        
        /// 장소 목록을 담는 상태 변수
        /// 신규 생성 시: PlaceSelection에서 주입
        /// 변경 시: .onAppear 시 전달받은 planner로부터 추출
        @State var selectedPlaces: [PlaceDTO]?
        
        @State var selectedPlace: PlaceDTO?
        @State var shouldProceed: Bool = false
        
        var body: some View {
            ZStack(alignment: .bottom) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: DesignToken.Spacing.xxxLarge) {
                        PlannerNameSection()
                        
                        ThumbnailSection()
                        
                        if let selectedPlaces {
                            PlaceListSection(selectedPlaces: selectedPlaces)
                        }
                    }
                    .padding(.horizontal, DesignToken.Spacing.large)
                }
                .frame(maxHeight: .infinity)
                
                BottomActionButton(
                    title: isNewPlanner ? "여행 만들기" : "저장하기",
                    isEnabled: plannerViewModel.plannerTitle != nil
                ) {
                    Task {
                        if isNewPlanner, let selectedPlaces {
                            await plannerViewModel.savePlanner(placeList: selectedPlaces)
                        }
                    }
                }
            }
            .onAppear {
                if !isNewPlanner {
                    configureForEditing()
                }
            }
            .navigationTitle(isNewPlanner ? "새로운 여행 만들기" : "여행 변경하기")
        }
    }
}

extension PlannerView.ComposeView {
    private func configureForEditing() {
        guard let planner else { return }
        plannerViewModel.planner = planner
        selectedPlaces = planner.placeList.map { $0.toPlaceDTO() }
        shouldProceed = true
    }
    
    private struct PlannerNameSection: View {
        @Environment(PlannerViewModel.self) var plannerViewModel
        
        var body: some View {
            CommonTextField(
                label: "제목 *",
                value: plannerViewModel.titleBinding,
                prompt: "여행의 제목을 입력하세요"
            )
        }
    }
    
    private struct ThumbnailSection: View {
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
    
    private struct PlaceListSection: View {
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
