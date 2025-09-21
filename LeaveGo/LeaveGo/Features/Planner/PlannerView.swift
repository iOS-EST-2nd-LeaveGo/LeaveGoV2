//
//  PlannerView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

struct PlannerView: View {
    @State private var path = NavigationPath()
    
    //let planners: [PlannerDTO] = mockPlanners
    let planners = [PlannerDTO]()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if !planners.isEmpty {
                    PlannerListView(plannerList: planners, path: $path)
                } else {
                    PlannerPlaceholderView(path: $path)
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

struct PlannerListView: View {
    var plannerList: [PlannerDTO]
    @Binding var path: NavigationPath
    
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: DesignToken.Spacing.large),
            GridItem(.flexible())
        ]
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: DesignToken.Spacing.large) {
                ForEach(plannerList) { planner in
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
    }
}

struct PlannerPlaceholderView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("아직 등록된 여행이 없어요")
                .foregroundStyle(.lgLabelSecondary)
            
            Spacer()
            
            PrimaryButton(
                title: "여행 추가하기",
                action: { path.append("newPlanner") }
            )
            .padding(.horizontal, DesignToken.Spacing.large)
        }
    }
}
