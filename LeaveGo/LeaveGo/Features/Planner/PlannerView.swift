//
//  PlannerView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

struct PlannerView: View {
    let planners: [Planner] = mockPlanners
    
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: DesignToken.Spacing.large),
            GridItem(.flexible())
        ]
        
        NavigationStack {
            VStack {
                if !planners.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: DesignToken.Spacing.large) {
                            ForEach(planners) { planner in
                                PlannerCardView(planner: planner)
                                    .cornerRadius(DesignToken.Radius.medium)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: DesignToken.Radius.medium)
                                            .strokeBorder(.lgBorderProminent, lineWidth: 1)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, DesignToken.Spacing.large)
                }
                
                Spacer()
            }
            .navigationTitle("나의 여행")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PlannerView()
}
