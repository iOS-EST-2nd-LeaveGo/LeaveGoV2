//
//  PlannerPlaceSelectionView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

struct PlannerPlaceSelectionView: View {
    let area: Area
    
    var body: some View {
        VStack {
            PlannerPlaceListView(area: area)
        }
        .navigationTitle(area.name)
    }
}

#Preview {
    PlannerPlaceSelectionView(area: .busan)
}
