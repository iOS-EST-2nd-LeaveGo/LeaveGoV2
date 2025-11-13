//
//  PlannerThumbnailView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

extension PlannerView {
    struct PlannerThumbnailView: View {
        let imageName: String?
        
        var body: some View {
            VStack {
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("PlaceholderImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .padding(10)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.lgBorder)
        }
    }
}

#Preview {
    PlannerView.PlannerThumbnailView(imageName: nil)
}
