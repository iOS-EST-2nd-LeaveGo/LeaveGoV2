//
//  PlannerPlaceListView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import SwiftUI

struct PlannerPlaceListView: View {
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
                        .sheet(item: $selectedPlaceForDetails) { place in
                            Text(place.title)
                                .presentationDetents([.fraction(0.4), .large])
                        }
                }
                .listStyle(.plain)
                .buttonStyle(.plain)
                .safeAreaInset(edge: .bottom) {
                    Color.clear
                        .frame(height: DesignToken.Layout.bottomActionButtonHeight)
                }

            } else {
                EmptyView()
            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    PlannerPlaceSelectionView(area: .busan)
}
