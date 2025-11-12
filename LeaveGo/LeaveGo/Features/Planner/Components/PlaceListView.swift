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
        
        @Binding var selectedPlaces: [PlaceDTO]
        @State var selectedPlaceForDetails: PlaceDTO?
        
        var body: some View {
            @State var places: [PlaceDTO] = plannerViewModel.placeList
            
            VStack {
                if !places.isEmpty {
                    List(places.indices, id: \.self) { index in
                        let place = places[index]
                        
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
                            .padding(.bottom, index == places.count - 1 ? DesignToken.Layout.bottomActionButtonHeight : .zero)
                            .onAppear {
                                if index == places.count - 20 {
                                    let maxPage = (plannerViewModel.totalCount + plannerViewModel.numOfRows - 1) / plannerViewModel.numOfRows
                                    if plannerViewModel.page < maxPage {
                                        plannerViewModel.page += 1
                                    }
                                }
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
        }
    }
}

#Preview {
    PlannerView.PlaceSelectionView()
        .environment(PlannerViewModel())
}
