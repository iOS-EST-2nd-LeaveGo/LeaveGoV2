//
//  PlannerView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import SwiftUI

/// 사용자의 여행 목록을 표시하는 메인 뷰
/// - 저장된 여행이 있으면 그리드 형태로 표시
/// - 저장된 여행이 없으면 플레이스홀더 뷰 표시
/// - 새 여행 생성 및 기존 여행 수정 네비게이션 처리
struct PlannerView: View {
    /// 네비게이션 스택 경로 관리
    @State private var path = NavigationPath()
    
    /// CoreData에서 여행 목록을 가져오는 FetchRequest (생성일 역순 정렬)
    @FetchRequest(sortDescriptors: [SortDescriptor(\Planner.createAt, order: .reverse)])
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
                // 새 여행 생성 플로우: AreaSelection → PlaceSelection → ComposeView
                if path == "newPlanner" {
                    AreaSelectionView()
                        .environment(PlannerViewModel())
                }
            }
            .navigationDestination(for: PlannerDTO.self) { planner in
                // 기존 여행 수정 플로우: ComposeView
                // 여행지 변경 시 ComposeView 내에서 Sheet 생성: AreaSelection → PlaceSelection
                ComposeView(planner: planner)
                    .environment(PlannerViewModel())
            }
        }
    }
}

extension PlannerView {
    /// 여행 목록을 2열 그리드로 표시하는 뷰
    /// - 각 여행은 PlannerCardView로 표시
    /// - 카드 클릭 시 수정 모드로 이동
    /// - 마지막에 "새 여행 추가" 카드 표시
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
    
    /// 저장된 여행이 없을 때 표시하는 플레이스홀더 뷰
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
