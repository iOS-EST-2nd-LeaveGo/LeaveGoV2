//
//  PlaceSelectionView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

extension PlannerView {
    /// 선택된 지역 내에서 여행지를 선택하는 뷰
    struct PlaceSelectionView: View {
        @Environment(PlannerViewModel.self) private var plannerViewModel

        /// 사용자가 선택한 장소 목록을 PlaceListView, ComposeView 간에 공유하기 위해 사용하는 상태 변수
        @State var selectedPlaces = [PlaceDTO]()
        /// navigationDestination용 바인딩 속성
        @State var shouldProceed: Bool = false

        var body: some View {
            ZStack(alignment: .bottom) {
                // 여행지 목록을 표시하는 메인 컨텐츠 뷰
                PlaceListView(selectedPlaces: $selectedPlaces)
                    .environment(plannerViewModel)
                    .frame(maxHeight: .infinity)

                BottomActionButton(
                    title: "추가하기",
                    isEnabled: !selectedPlaces.isEmpty) {
                        shouldProceed = true
                        plannerViewModel.placeList = selectedPlaces
                    }
            }
            .navigationTitle("여행지 선택하기")
            .navigationDestination(
                isPresented: $shouldProceed) {
                    ComposeView(selectedPlaces: selectedPlaces)
                        .environment(plannerViewModel)
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
