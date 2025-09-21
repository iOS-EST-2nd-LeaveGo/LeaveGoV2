//
//  PlannerPlaceSelectionView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

struct PlannerPlaceSelectionView: View {
    let area: Area
    
    @State var selectedPlaces = [Place]()
    @State var shouldProceed: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            PlannerPlaceListView(area: area, selectedPlaces: $selectedPlaces)
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
                PlannerComposeView(selectedPlaces: selectedPlaces)
            }
    }
}

#Preview {
    PlannerPlaceSelectionView(area: .busan)
}
