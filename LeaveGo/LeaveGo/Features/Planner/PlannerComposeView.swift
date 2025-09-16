//
//  PlannerComposeView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/15/25.
//

import SwiftUI

struct PlannerComposeView: View {
    @Environment(\.dismiss) var dismiss
    
    let selectedPlaces: [Place]
    
    @State var plannerTitle = ""
    @State var shouldProceed: Bool = false
    @State var selectedPlaceForDetails: Place?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignToken.Spacing.xxxLarge) {
                    CommonTextField(
                        label: "제목 *",
                        value: $plannerTitle,
                        prompt: "여행의 제목을 입력하세요"
                    )
                    
                    VStack(alignment: .leading, spacing: DesignToken.Spacing.medium) {
                        Text("썸네일")
                            .padding(.leading, DesignToken.Spacing.small)
                            .font(.footnote)
                            .foregroundStyle(.lgLabelSecondary)
                        
                        PlaceholderImageView(width: 80)
                    }
                    
                    VStack(spacing: DesignToken.Spacing.medium) {
                        HStack {
                            Text("여행지 *")
                                .padding(.leading, DesignToken.Spacing.small)
                                .font(.footnote)
                                .foregroundStyle(.lgLabelSecondary)
                            
                            Spacer()
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("여행지 다시 선택하기")
                                    .foregroundStyle(.lgAccent)
                                    .font(.footnote)
                            }
                        }
                        
                        LazyVStack(spacing: DesignToken.Spacing.xxLarge) {
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

#Preview {
    PlannerComposeView(selectedPlaces: mockPlaceArray)
}
