//
//  PlannerCardView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

struct PlannerCardView: View {
    let planner: Planner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PlannerThumbnailView(imageName: planner.thumbnailPath)
                .frame(minHeight: 160)
                .clipped()
            
            Text(planner.title)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(DesignToken.Spacing.large)
                .frame(maxHeight: .infinity)
        }
        .aspectRatio(3/4, contentMode: .fit)
        .overlay {
            RoundedRectangle(cornerRadius: DesignToken.Radius.small)
                .stroke(Color("ProminentBorderColor"), lineWidth: 1)
        }
    }
}

#Preview {
    PlannerCardView(planner: mockPlanners.first!)
}
