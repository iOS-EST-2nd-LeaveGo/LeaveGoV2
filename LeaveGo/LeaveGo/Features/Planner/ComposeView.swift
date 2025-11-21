//
//  ComposeView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/15/25.
//

import SwiftUI
import PhotosUI

extension PlannerView {
    /// 여행 생성 및 기존 여행 수정을 위한 뷰
    struct ComposeView: View {
        @Environment(PlannerViewModel.self) var plannerViewModel
        @Environment(\.dismiss) var dismiss
        
        /// 여행을 담는 변수
        /// nil이면 여행 신규 생성, 데이터가 있으면 기존 여행 수정
        var planner: PlannerDTO? = nil
        
        /// 생성/수정 모드를 구분하는 computed property
        private var isNewPlanner: Bool {
            return planner == nil
        }
        
        /// 현재 표시할 장소 목록을 담는 상태 변수
        /// - 신규 생성 시: PlaceSelection에서 주입받은 데이터
        /// - 수정 시: 기존 planner 데이터 + 새로 선택한 데이터 (시트 닫힘 시 업데이트)
        @State var selectedPlaces: [PlaceDTO]?
        
        /// 사용자가 선택한 여행지의 상세 정보 시트를 열기 위한 상태 변수
        @State var selectedPlace: PlaceDTO?
        
        /// 저장 버튼의 활성화 여부를 결정하는 상태 변수 (여행 제목이 입력되면 true)
        @State var shouldProceed: Bool = false
        
        var body: some View {
            ZStack(alignment: .bottom) {
                // 메인 스크롤 컨텐츠
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignToken.Spacing.xxxLarge) {
                        // 여행 제목 입력 섹션
                        PlannerNameSection()
                            .padding(.horizontal, DesignToken.Spacing.large)
                        
                        // 썸네일 이미지 선택 섹션
                        ThumbnailSection()
                            .padding(.horizontal, DesignToken.Spacing.large)
                        
                        // 선택된 여행지 목록 표시
                        if selectedPlaces != nil {
                            PlaceListSection(selectedPlaces: $selectedPlaces, isNewPlanner: isNewPlanner)
                                .environment(plannerViewModel)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                // 하단 고정 액션 버튼
                BottomActionButton(
                    title: isNewPlanner ? "여행 만들기" : "여행 저장하기",
                    isEnabled: shouldProceed
                ) {
                    Task {
                        if let selectedPlaces {
                            await plannerViewModel.savePlanner(placeList: selectedPlaces)
                            // 생성/수정 모드에 따라 네비게이션 효과 다르게 적용
                            // 생성 시: 새로운 NavigationPath를 인스턴싱해 Root로 한번에 Pop
                            // 수정 시: 이전 View로 한 단계 Pop
                            if isNewPlanner {
                                await MainActor.run {
                                    plannerViewModel.navigationPath?.wrappedValue = NavigationPath()
                                }
                            } else {
                                dismiss()
                            }
                        }
                    }
                }
            }
            .onAppear {
                // 수정 모드일 때 초기 데이터 설정
                if !isNewPlanner { configureForEditing() }
                // 저장 버튼의 상태를 업데이트
                shouldProceed = !(plannerViewModel.titleBinding.wrappedValue.isEmpty)
            }
            .onChange(of: plannerViewModel.plannerTitle, { _, newValue in
                // 여행 제목이 입력되면 저장 버튼 활성화
                shouldProceed = (newValue != nil)
            })
            .onChange(of: plannerViewModel.shouldOpenSheet, { _, newValue in
                // 여행지 재선택 시트를 닫을 때 여행지 목록을 새 목록으로 동기화
                if newValue == false {
                    Task {
                        if !plannerViewModel.modifiedPlaceList.isEmpty {
                            selectedPlaces = plannerViewModel.modifiedPlaceList
                        }
                    }
                }
            })
            .navigationTitle(isNewPlanner ? "새로운 여행 만들기" : "여행 변경하기")
        }
    }
}

extension PlannerView.ComposeView {
    /// 파라메터로 전달된 여행 데이터로 수정 모드를 준비
    private func configureForEditing() {
        guard let planner else { return }
        plannerViewModel.planner = planner
        selectedPlaces = planner.placeList.map { $0.toPlaceDTO() }
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
    
    /// 선택된 여행지 목록을 표시하고 관리하는 섹션
    private struct PlaceListSection: View {
        @Environment(PlannerViewModel.self) var plannerViewModel
        @Environment(\.dismiss) var dismiss
        
        @Binding var selectedPlaces: [PlaceDTO]?
        let isNewPlanner: Bool
        
        /// 상세 정보 시트에 표기할 여행지
        @State var selectedPlace: PlaceDTO?
        /// 여행지 재선택 확인 알럿 표시 여부
        @State var shouldOpenAlert: Bool = false
        
        /// 각 행의 높이
        /// ScrollView 안에 있는 List의 특성 상 전체 높이를 계산해 지정해줘야 함
        @State var rowHeight: CGFloat = 0
        @State var listHeight: CGFloat = 0
        /// List의 전체 높이를 계산하는 함수
        private func calculateListHeight() -> CGFloat {
            guard let selectedPlaces else { return 0 }
            
            let placeCount = CGFloat(selectedPlaces.count)
            let contentHeight = placeCount * rowHeight
            let spacing = placeCount * 31
            let padding = DesignToken.Layout.bottomActionButtonHeight
            
            let result = contentHeight + spacing + padding
            
            return result
        }
        
        /// 여행지 순서를 변경하는 함수
        private func move(from source: IndexSet, to destination: Int) {
            guard var places = selectedPlaces else { return }
            places.move(fromOffsets: source, toOffset: destination)
            selectedPlaces = places
        }
        
        private func delete(_ source: IndexSet) {
            guard var places = selectedPlaces else { return }
            places.remove(atOffsets: source)
            selectedPlaces = places
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
                                            listHeight = calculateListHeight()
                                        }
                                    }
                                }
                            )
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)
                }
            }
            .onChange(of: selectedPlaces, { _, _ in
                    listHeight = calculateListHeight()
            })
            .listStyle(.plain)
            .scrollDisabled(true) // List의 자체 스크롤은 비활성화, 상위 ScrollView에서 전체 페이지 스크롤
            .frame(minHeight: 300)
            .frame(
                height: listHeight,
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
