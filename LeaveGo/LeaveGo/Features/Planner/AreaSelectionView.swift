//
//  AreaSelectionView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

extension PlannerView {
    /// 여행 지역을 선택하는 뷰
    /// PlannerViewModel을 생성하여 하위 뷰들로 전달
    /// 지역 선택 전 단계로 돌아가면 ViewModel 해제 후 다시 생성
    struct AreaSelectionView: View {
        @State private var plannerViewModel = PlannerViewModel()

        /// 현재 선택된 지역
        @State private var selectedArea: Area?
        /// navigationDestination용 바인딩 속성
        @State private var shouldProceed = false

        /// 선택 가능한 모든 지역 목록
        private let availableAreas: [Area] = Area.allCases
        
        var body: some View {
            // 3열 그리드 레이아웃 설정
            let gridColumns: [GridItem] = { Array(
                repeating: GridItem(.flexible(), spacing: DesignToken.Spacing.large),
                count: 3)
            }()

            ZStack(alignment: .bottom) {
                // 지역 선택 그리드
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: DesignToken.Spacing.large) {
                        ForEach(availableAreas, id: \.self) { area in
                            Button {
                                selectedArea = area
                            } label: {
                                AreaButtonView(area: area, isSelected: selectedArea == area)
                            }
                        }
                    }
                    .padding(.bottom, DesignToken.Layout.bottomActionButtonHeight)
                }
                .padding(.horizontal, DesignToken.Spacing.large)

                BottomActionButton(
                    title: "다음",
                    isEnabled: selectedArea != nil) {
                        shouldProceed = true

                        // 불필요한 API 호출 방지: 기존 선택 지역과 다를 때만 업데이트
                        if plannerViewModel.selectedArea != selectedArea {
                            plannerViewModel.selectedArea = selectedArea
                        }
                    }
            }
            .navigationTitle("여행 지역 선택하기")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(
                isPresented: $shouldProceed) {
                    PlaceSelectionView()
                        .environment(plannerViewModel)
                }
        }
    }
    
    /// 지역 선택 버튼 컴포넌트
    struct AreaButtonView: View {
        var area: Area
        let isSelected: Bool

        var body: some View {
            Text(area.name)
                .font(.system(size: 14))
                .fontWeight(isSelected ? .bold : .regular)
                .tint(isSelected ? .lgAccent : .lgLabel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? .lgBackgroundAccentLight : .lgTextField)
                        .strokeBorder(isSelected ? .lgAccent : .lgBackgroundAccentLight)
                )
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

#Preview {
    NavigationStack {
        PlannerView.AreaSelectionView()
            .environment(PlannerViewModel())
    }
}
