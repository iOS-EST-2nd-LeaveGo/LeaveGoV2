//
//  PlannerPlaceListView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

struct PlannerPlaceListView: View {
    @State var places = [Place]()
    @State var shouldProceed: Bool = false
    @State var selectedPlaces = Set<Place>()
    @State var selectedPlaceForDetails: Place?
    
    let area: Area
    
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
                                    print(selectedPlaces.map { $0.title })
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
                    
                    BottomActionButton(
                        title: "추가하기",
                        isEnabled: !selectedPlaces.isEmpty) {
                            shouldProceed = true
                        }
                }
                .navigationDestination(
                    isPresented: $shouldProceed) {
                        
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
