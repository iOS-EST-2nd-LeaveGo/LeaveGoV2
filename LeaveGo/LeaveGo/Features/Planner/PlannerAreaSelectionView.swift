//
//  PlannerAreaSelectionView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

struct PlannerAreaSelectionView: View {
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
                }
        }
        .navigationTitle("여행 지역 선택하기")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(
            isPresented: $shouldProceed) {
                if let selectedArea {
                    PlannerPlaceSelectionView(area: selectedArea)
                }
            }
    }
}

#Preview {
    NavigationStack {
        PlannerAreaSelectionView()
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
