//
//  PlaceSelectionView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

extension PlannerView {
    struct PlaceSelectionView: View {
        let area: Area
        
        @State var selectedPlaces = [PlaceDTO]()
        @State var shouldProceed: Bool = false
        
        var body: some View {
            ZStack(alignment: .bottom) {
                PlaceListView(area: area, selectedPlaces: $selectedPlaces)
                    .frame(maxHeight: .infinity)
                
                BottomActionButton(
                    title: "추가하기",
                    isEnabled: !selectedPlaces.isEmpty) {
                        shouldProceed = true
                        print("\(selectedPlaces.map { $0.title })")
                    }
            }
            .navigationTitle("여행지 선택하기")
            .navigationDestination(
                isPresented: $shouldProceed) {
                    ComposeView(selectedPlaces: selectedPlaces)
                }
        }
    }
}

#Preview {
    PlannerView.PlaceSelectionView(area: .busan)
}
