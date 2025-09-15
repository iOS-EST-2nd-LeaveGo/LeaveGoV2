//
//  PlannerAreaSelectionView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

struct PlannerAreaSelectionView: View {
    @State private var selectedArea: Area?
    
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
            }
            .padding(.horizontal, DesignToken.Spacing.large)
            
            BottomActionButton(
                title: "다음",
                isEnabled: selectedArea != nil) {
                    print(selectedArea!)
                }
        }
        .navigationTitle("여행 지역 선택하기")
        .navigationBarTitleDisplayMode(.inline)
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
