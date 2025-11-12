//
//  AreaSelectionView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

extension PlannerView {
    struct AreaSelectionView: View {
        @State private var plannerViewModel = PlannerViewModel()
        
        @State private var selectedArea: Area?
        @State private var shouldProceed = false
        
        private let availableAreas: [Area] = Area.allCases
        
        var body: some View {
            let gridColumns: [GridItem] = { Array(
                repeating: GridItem(.flexible(), spacing: DesignToken.Spacing.large),
                count: 3)
            }()
            
            ZStack(alignment: .bottom) {
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
                        
                        // 기존에 선택된 지역과 같은 경우에는 selectedArea를 변경하지 않기
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
