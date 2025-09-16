//
//  PlannerComposeView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/15/25.
//

import SwiftUI

struct PlannerComposeView: View {
    let selectedPlaces: [Place]
    
    @State var plannerTitle = ""
    @State var shouldProceed: Bool = false
    @State var selectedPlaceForDetails: Place?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignToken.Spacing.xxxLarge) {
                    PlannerNameSection(value: $plannerTitle)
                    
                    ThumbnailSection()
                    
                    PlaceListSection(selectedPlaces: selectedPlaces)
                }
                .padding(.horizontal, DesignToken.Spacing.large)
            }
            .frame(maxHeight: .infinity)
            
            BottomActionButton(
                title: "여행 만들기",
                isEnabled: !plannerTitle.isEmpty
            ) {
                print("\(plannerTitle) 여행 생성: \(selectedPlaces.map { $0.title })")
            }
        }
        .navigationTitle("새로운 여행 만들기")
        .onAppear {
            print("\(selectedPlaces.map { $0.title })")
        }
    }
}

struct PlannerNameSection: View {
    @Binding var value: String
    
    var body: some View {
        CommonTextField(
            label: "제목 *",
            value: $value,
            prompt: "여행의 제목을 입력하세요"
        )
    }
}

struct ThumbnailSection: View {
    @State var photoItem: PhotosPickerItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignToken.Spacing.medium) {
            SectionHeader(title: "썸네일")
            
            PlaceholderImageView(width: 80)
        }
    }
}

struct PlaceListSection: View {
    @Environment(\.dismiss) var dismiss
    
    let selectedPlaces: [Place]
    
    @State var selectedPlaceForDetails: Place?
    
    var body: some View {
        VStack(spacing: DesignToken.Spacing.medium) {
            HStack {
                SectionHeader(title: "여행지 *")
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    SectionButtonLabel(title: "여행지 다시 선택하기")
                }
            }
            
            LazyVStack(spacing: DesignToken.Spacing.large) {
                ForEach(selectedPlaces) { place in
                    PlaceListRow(
                        place: place,
                        listMode: .draggable,
                        rowAction: nil) {
                            selectedPlaceForDetails = place
                        }
                        .sheet(item: $selectedPlaceForDetails) { place in
                            Text(place.title)
                                .presentationDetents([.fraction(0.4), .large])
                        }
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    PlannerComposeView(selectedPlaces: mockPlaceArray)
}
