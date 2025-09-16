//
//  PlannerComposeView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/15/25.
//

import SwiftUI

struct PlannerComposeView: View {
    let selectedPlaces: Set<Place>
    
    var body: some View {
        Text("\(selectedPlaces.map { $0.title })")
    }
}

#Preview {
    PlannerComposeView(selectedPlaces: mockPlaceSet)
}

let mockPlaceSet: Set<Place> = [mockPlace1, mockPlace2]
