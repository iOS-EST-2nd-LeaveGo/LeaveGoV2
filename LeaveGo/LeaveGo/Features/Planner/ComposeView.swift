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
        
        /// CTA 버튼의 활성화 여부를 담는 상태 변수
        @State var shouldProceed: Bool = false
        
        var body: some View {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignToken.Spacing.xxxLarge) {
                        PlannerNameSection()
                            .padding(.horizontal, DesignToken.Spacing.large)
                        
                        ThumbnailSection()
                            .padding(.horizontal, DesignToken.Spacing.large)
                        
                        if selectedPlaces != nil {
                            PlaceListSection(selectedPlaces: $selectedPlaces, isNewPlanner: isNewPlanner)
                                .environment(plannerViewModel)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                BottomActionButton(
                    title: isNewPlanner ? "여행 만들기" : "여행 저장하기",
                    isEnabled: shouldProceed
                ) {
                    Task {
                        if let selectedPlaces {
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
            .onChange(of: plannerViewModel.plannerTitle, { _, newValue in
                shouldProceed = (newValue != nil)
            })
            .onChange(of: plannerViewModel.shouldOpenSheet, { _, newValue in
                if newValue == false {
                    Task {
                        try await Task.sleep(for: .seconds(0.5))
                        if !plannerViewModel.placeList.isEmpty {
                            selectedPlaces = plannerViewModel.placeList
                        }
                    }
                }
            })
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
        @Environment(PlannerViewModel.self) var plannerViewModel
        @Environment(\.dismiss) var dismiss
        
        @Binding var selectedPlaces: [PlaceDTO]?
        let isNewPlanner: Bool
        
        @State var selectedPlace: PlaceDTO?
        @State var shouldOpenAlert: Bool = false
        @State var rowHeight: CGFloat = 0
        
        private func move(from source: IndexSet, to destination: Int) {
            guard var places = selectedPlaces else { return }
            places.move(fromOffsets: source, toOffset: destination)
            selectedPlaces = places
        }
        
        private func calculateListHeight() -> CGFloat {
            let placeCount = CGFloat(selectedPlaces?.count ?? 0)
            let contentHeight = placeCount * rowHeight
            let bottomPadding = DesignToken.Layout.bottomActionButtonHeight + DesignToken.Spacing.xxxLarge
            let spacing = placeCount > 1 ? (placeCount - 1) * 28 : 0
            
            return contentHeight + bottomPadding + spacing
        }
        
        var body: some View {
            VStack(spacing: DesignToken.Spacing.medium) {
                HStack {
                    SectionHeader(title: "여행지 *")
                    
                    Spacer()
                    
                    Button {
                        if isNewPlanner {
                            dismiss()
                        } else {
                            shouldOpenAlert = true
                        }
                    } label: {
                        SectionButtonLabel(title: "여행지 다시 선택하기")
                    }
                }
                .padding(.horizontal, DesignToken.Spacing.large)
                
                List {
                    ForEach(selectedPlaces ?? []) { place in
                        PlaceListRow(
                            place: place,
                            listMode: .draggable,
                            rowAction: nil) {
                                selectedPlace = place
                            }
                            .background(
                                GeometryReader { geo in
                                    Color.clear.onAppear {
                                        if rowHeight == 0 {
                                            rowHeight = geo.size.height
                                        }
                                    }
                                }
                            )
                    }
                    .onMove(perform: move)
                }
            }
            .listStyle(.plain)
            .scrollDisabled(true)
            .frame(
                height: calculateListHeight(),
                alignment: .top
            )
            .sheet(item: $selectedPlace) { place in
                PlaceDetailSheetView(place: place, buttonTitle: "경로 찾기")
                    .presentationDetents([.fraction(0.4), .large])
            }
            .alert(
                "여행지 다시 선택하기",
                isPresented: $shouldOpenAlert,
                actions: {
                    Button("확인") {
                        plannerViewModel.shouldOpenSheet = true
                    }
                    
                    Button("취소", role: .cancel) { }
                },
                message: {
                    Text("기존에 추가했던 모든 여행지를 삭제하고 다시 선택하시겠어요?")
                }
            )
            .sheet(isPresented: plannerViewModel.sheetStatusBinding) {
                plannerViewModel.shouldOpenSheet = false
            } content: {
                NavigationStack {
                    PlannerView.AreaSelectionView()
                        .environment(plannerViewModel)
                        .presentationDetents([.fraction(0.8), .large])
                }
            }
        }
    }
}

#Preview("여행 생성 시") {
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

#Preview("여행 수정 시") {
    let previewPlanner = PlannerDTO(
        id: UUID(),
        title: "서울",
        startDate: Date(),
        endDate: Date(),
        thumbnail: "",
        placeList: [
            PlannerPlaceDTO(
                id: UUID(),
                title: "광화문1",
                contentID: "1",
                contentTypeID: "111",
                thumbnail: nil,
                date: Date(),
                order: 1
            ),
            PlannerPlaceDTO(
                id: UUID(),
                title: "광화문2",
                contentID: "2",
                contentTypeID: "111",
                thumbnail: nil,
                date: Date(),
                order: 1
            )
        ]
    )
    
    PlannerView.ComposeView(planner: previewPlanner)
        .environment(PlannerViewModel())
}
