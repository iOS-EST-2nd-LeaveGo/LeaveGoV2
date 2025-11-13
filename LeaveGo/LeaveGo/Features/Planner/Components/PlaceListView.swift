//
//  PlaceListView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

extension PlannerView {
    /// 선택된 지역의 여행지 목록을 표시하고 선택할 수 있는 뷰
    struct PlaceListView: View {
        @Environment(PlannerViewModel.self) private var plannerViewModel
        
        /// 상위 뷰와 공유하는 선택된 여행지 목록
        @Binding var selectedPlaces: [PlaceDTO]
        /// 상세 정보 시트에 표시할 여행지
        @State var selectedPlaceForDetails: PlaceDTO?
        
        var body: some View {
            let places: [PlaceDTO] = plannerViewModel.placeList
            
            VStack {
                if !places.isEmpty {
                    List(places.indices, id: \.self) { index in
                        let place = places[index]
                        
                        PlaceListRow(
                            place: place,
                            listMode: .selectable) {
                                // 장소 선택/선택해제 토글 로직
                                if let selectedIndex = selectedPlaces.firstIndex(of: place) {
                                    selectedPlaces.remove(at: selectedIndex)
                                } else {
                                    selectedPlaces.append(place)
                                }
                            } accessoryAction: {
                                // 상세 정보 시트 표시
                                selectedPlaceForDetails = place
                            }
                            // 리스트의 마지막 항목에 하단 버튼 공간 확보
                            .padding(.bottom, index == places.count - 1 ? DesignToken.Layout.bottomActionButtonHeight : .zero)
                            .onAppear {
                                // 무한 스크롤: 끝에서 20개 전에 도달하면 다음 페이지 로드
                                if index == places.count - 20 {
                                    // 최대 페이지 계산하여 불필요한 API 호출 방지
                                    let maxPage = (plannerViewModel.totalCount + plannerViewModel.numOfRows - 1) / plannerViewModel.numOfRows
                                    if plannerViewModel.page < maxPage {
                                        plannerViewModel.page += 1
                                    }
                                }
                            }
                    }
                    .listStyle(.plain)
                    .buttonStyle(.plain)
                    // 여행지 상세 정보 시트
                    .sheet(item: $selectedPlaceForDetails) { place in
                        PlaceDetailSheetView(place: place, buttonTitle: "경로 찾기")
                            .presentationDetents([.fraction(0.4), .large])
                    }
                } else {
                    // 데이터 로딩 표시
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlannerView.AreaSelectionView()
            .environment(PlannerViewModel())
    }
}
