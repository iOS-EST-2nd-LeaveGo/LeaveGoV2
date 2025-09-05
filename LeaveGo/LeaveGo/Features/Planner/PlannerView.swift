//
//  PlannerView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

struct PlannerView: View {
    @State private var path = NavigationPath()
    
    let planners: [Planner] = mockPlanners
    //let planners = [Planner]()
    
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: DesignToken.Spacing.large),
            GridItem(.flexible())
        ]
        
        NavigationStack(path: $path) {
            VStack {
                if !planners.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: DesignToken.Spacing.large) {
                            ForEach(planners) { planner in
                                PlannerCardView(planner: planner)
                            }
                            
                            Button {
                                path.append("newPlanner")
                            } label: {
                                PlannerCardView(planner: nil)
                            }
                        }
                    }
                    .padding(.horizontal, DesignToken.Spacing.large)
                } else {
                    VStack {
                        Spacer()
                        
                        Text("아직 등록된 여행이 없어요")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Button("여행 추가하기") {
                            path.append("newPlanner")
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("나의 여행")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { value in
                if value == "newPlanner" {
                    PlannerAreaSelectionView()
                }
            }
        }
    }
}

#Preview {
    PlannerView()
}
