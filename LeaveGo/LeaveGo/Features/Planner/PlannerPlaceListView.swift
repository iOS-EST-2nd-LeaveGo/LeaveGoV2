//
//  PlannerPlaceListView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

struct PlannerPlaceListView: View {
    let area: Area
    @Binding var selectedPlaces: Set<Place>
    
    @State var places = [Place]()
    @State var selectedPlaceForDetails: Place?
    
    var body: some View {
        ZStack {
            if !places.isEmpty {
                ScrollView {
                    LazyVStack(spacing: .zero) {
                        ForEach(places) { place in
                            PlaceListRow(
                                place: place,
                                listMode: .selectable) {
                                    let isSelected = selectedPlaces.contains(place)
                                    if !isSelected {
                                        selectedPlaces.insert(place)
                                    } else {
                                        selectedPlaces.remove(place)
                                    }
                                } accessoryAction: {
                                    selectedPlaceForDetails = place
                                }
                                .sheet(item: $selectedPlaceForDetails) { place in
                                    Text(place.title)
                                        .presentationDetents([.fraction(0.4), .large])
                                }
                        }
                    }
                    .padding(.horizontal, DesignToken.Spacing.large)
                }
            } else {
                EmptyView()
            }
        }
        .onAppear {
            places = mockPlaceArray
        }
    }
}

#Preview {
    PlannerPlaceSelectionView(area: .busan)
}
