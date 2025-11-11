//
//  PlaceListView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

extension PlannerView {
    struct PlaceListView: View {
        @Environment(PlannerViewModel.self) private var plannerViewModel
        
        let area: Area
        @Binding var selectedPlaces: [PlaceDTO]
        
        @State var places = [PlaceDTO]()
        @State var selectedPlaceForDetails: PlaceDTO?
        
        var body: some View {
            VStack {
                if !places.isEmpty {
                    List(places) { place in
                        PlaceListRow(
                            place: place,
                            listMode: .selectable) {
                                if let index = selectedPlaces.firstIndex(of: place) {
                                    selectedPlaces.remove(at: index)
                                } else {
                                    selectedPlaces.append(place)
                                }
                            } accessoryAction: {
                                selectedPlaceForDetails = place
                            }
                    }
                    .listStyle(.plain)
                    .buttonStyle(.plain)
                    .sheet(item: $selectedPlaceForDetails) { place in
                        PlaceDetailSheetView(place: place, buttonTitle: "경로 찾기")
                            .presentationDetents([.fraction(0.4), .large])
                    }
                } else {
                    ProgressView()
                }
            }
            .task {
                await plannerViewModel.fetchPlaceList(of: area)
                places = plannerViewModel.placeList
            }
        }
    }
}

#Preview {
    PlannerView.PlaceSelectionView(area: .busan)
        .environment(PlannerViewModel())
}
