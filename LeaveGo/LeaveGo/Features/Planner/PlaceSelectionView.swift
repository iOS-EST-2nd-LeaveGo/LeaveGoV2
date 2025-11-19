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
        
        private var isNewPlanner: Bool {
            return plannerViewModel.planner == nil
        }

        /// 사용자가 선택한 장소 목록을 담는 상태 변수
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
                        if isNewPlanner {
                            // 여행 생성 시: 추가하기 버튼을 누르면 다음 화면(ComposeView) Push
                            shouldProceed = true
                        } else {
                            // 여행 수정 시: 추가하기 버튼을 누르면 여행지 선택 플로우를 종료하므로 ViewModel에 여행지 업데이트
                            plannerViewModel.modifiedPlaceList = selectedPlaces
                            plannerViewModel.shouldOpenSheet = false
                        }
                    }
            }
            .navigationTitle("여행지 선택하기")
            .navigationDestination(
                isPresented: $shouldProceed) {
                    if isNewPlanner {
                        ComposeView(selectedPlaces: selectedPlaces)
                            .environment(plannerViewModel)
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
