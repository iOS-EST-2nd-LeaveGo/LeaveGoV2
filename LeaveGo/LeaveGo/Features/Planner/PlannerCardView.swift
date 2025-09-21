//
//  PlannerCardView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

struct PlannerCardView: View {
    let planner: PlannerDTO?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let planner {
                PlannerThumbnailView(imageName: planner.thumbnailPath)
                    .frame(minHeight: 160)
                    .clipped()
                
                Text(planner.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(DesignToken.Spacing.large)
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
        .overlay {
            RoundedRectangle(cornerRadius: DesignToken.Radius.small)
                .strokeBorder(.lgBorderProminent, lineWidth: 1)
        }
    }
}

#Preview {
    PlannerCardView(planner: mockPlanners.first!)
        .padding()
}
