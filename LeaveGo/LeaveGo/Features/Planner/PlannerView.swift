//
//  PlannerView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

struct PlannerView: View {
    @State private var path = NavigationPath()
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\Planner.title, order: .reverse)])
    private var planners: FetchedResults<Planner>
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if !planners.isEmpty {
                    PlannerListView(plannerList: planners.map { $0.toPlannerDTO() }, path: $path)
                } else {
                    PlannerPlaceholderView(path: $path)
                }
                
                Spacer()
            }
            .navigationTitle("나의 여행")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { path in
                if path == "newPlanner" {
                    AreaSelectionView()
                        .environment(PlannerViewModel())
                }
            }
            .navigationDestination(for: PlannerDTO.self) { planner in
                ComposeView(planner: planner)
                    .environment(PlannerViewModel())
            }
        }
    }
}

extension PlannerView {
    struct PlannerListView: View {
        var plannerList: [PlannerDTO]
        @Binding var path: NavigationPath
        
        let columns = [
            GridItem(.flexible(), spacing: DesignToken.Spacing.large),
            GridItem(.flexible())
        ]
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: DesignToken.Spacing.large) {
                    ForEach(plannerList) { planner in
                        NavigationLink(value: planner) {
                            PlannerCardView(planner: planner)
                        }
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
}

#Preview {
    PlannerView()
}
