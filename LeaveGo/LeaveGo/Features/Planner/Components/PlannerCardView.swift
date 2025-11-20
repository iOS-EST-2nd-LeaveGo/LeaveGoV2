//
//  PlannerCardView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

extension PlannerView {
    struct PlannerCardView: View {
        let planner: PlannerDTO?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if let planner {
                    PlannerThumbnailView(imageName: planner.thumbnail)
                        .frame(minHeight: 160)
                        .clipped()
                    
                    Text(planner.title)
                        .foregroundStyle(.lgLabel)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .padding(.horizontal, DesignToken.Spacing.large)
                        .padding(.vertical, DesignToken.Spacing.medium)
                        .frame(maxHeight: .infinity)
                } else {
                    VStack {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundStyle(.lgBorderProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.lgBorder)
                }
            }
            .aspectRatio(3/4, contentMode: .fit)
            .cornerRadius(DesignToken.Radius.small)
            .background(.lgBackground) // 여행 제목 영역의 빈 공간까지 LongPress 제스처 영역을 늘리고자 배경색 추가
            .overlay {
                RoundedRectangle(cornerRadius: DesignToken.Radius.small)
                    .strokeBorder(.lgBorderProminent, lineWidth: 1)
            }
        }
    }
}

#Preview {
    let previewPlanner: PlannerDTO = PlannerDTO(
        id: UUID(),
        title: "광화문 여행",
        startDate: Date(),
        endDate: Date(),
        thumbnail: nil,
        placeList: [
            PlannerPlaceDTO(
                id: UUID(),
                title: "광화문",
                contentID: "1",
                contentTypeID: "12",
                thumbnail: nil,
                date: Date(),
                order: 1)
        ]
    )
    
    PlannerView.PlannerCardView(planner: previewPlanner)
        .padding()
}
