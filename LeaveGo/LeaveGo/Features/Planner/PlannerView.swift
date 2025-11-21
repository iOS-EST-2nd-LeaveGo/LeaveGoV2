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
                    PlannerListView(planners: planners, path: $path)
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
                    let plannerViewModel = PlannerViewModel()
                    
                    AreaSelectionView()
                        .environment(plannerViewModel)
                        .onAppear {
                            // 신규 여행 등록 시에 루트뷰로 한 번에 pop하기 위해 네비게이션 스택을 뷰모델에 저장하기
                            plannerViewModel.navigationPath = $path
                        }
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
        let plannerRepository = PlannerRepository()
        let planners: FetchedResults<Planner>
        
        @Binding var path: NavigationPath
        
        @State var showDeleteAlert: Bool = false
        @State var plannerToDelete: PlannerDTO? = nil
        
        private var plannerList: [PlannerDTO] {
            planners.map { $0.toPlannerDTO() }
        }
        
        let columns = [
            GridItem(.flexible(), spacing: DesignToken.Spacing.large),
            GridItem(.flexible())
        ]
        
        private func deletePlanner(planner: PlannerDTO) {
            if let plannerObject = planners.first(where: { $0.id == planner.id }) {
                Task {
                    try await plannerRepository.deletePlanner(plannerObject.objectID)
                    resetDeleteData()
                }
            }
        }
        
        private func resetDeleteData() {
            plannerToDelete = nil
            showDeleteAlert = false
        }
        
        var body: some View {
            ScrollView {
                Text("ⓘ 여행을 길게 눌러 삭제할 수 있어요")
                    .font(.footnote)
                    .foregroundStyle(.lgLabelSecondary)
                
                LazyVGrid(columns: columns, spacing: DesignToken.Spacing.large) {
                    
                    ForEach(plannerList) { planner in
                        NavigationLink(value: planner) {
                            PlannerCardView(planner: planner)
                                .onLongPressGesture {
                                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                    plannerToDelete = planner
                                    showDeleteAlert = true
                                }
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
            .animation(.easeInOut(duration: 0.3), value: plannerList)
            .alert("여행 삭제", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    if let plannerToDelete {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            deletePlanner(planner: plannerToDelete)
                        }
                        resetDeleteData()
                    }
                }
                
                Button("취소", role: .cancel) {
                    resetDeleteData()
                }
            } message: {
                if let plannerToDelete {
                    Text("\(plannerToDelete.title)을 정말 삭제하시겠어요? 이 작업은 되돌릴 수 없어요")
                }
            }
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
