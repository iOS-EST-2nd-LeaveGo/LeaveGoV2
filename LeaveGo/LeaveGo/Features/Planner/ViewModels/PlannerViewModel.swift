//
//  PlannerViewModel.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/11/25.
//

import Foundation
import SwiftUI

/// Planner 관련 여행지 데이터와 상태를 관리하는 뷰모델
@Observable
final class PlannerViewModel {
    /// 여행지 API 요청을 처리하는 리포지토리
    let placeRepository = PlaceRepository()
    let plannerRepository = PlannerRepository()

    /// 선택된 지역 (변경 시 자동으로 첫 페이지의 데이터 불러오기)
    var selectedArea: Area? {
        didSet {
            // 기존에 다른 지역이 선택되어 있었다면 상태 초기화
            if oldValue != nil {
                page = 1
                totalCount = 0
                placeList = []
            }
            Task {
                await fetchPlaceList()
            }
        }
    }

    /// 현재 페이지 번호 (변경 시 자동으로 해당 페이지의 데이터 불러오기)
    var page: Int = 1 {
        didSet {
            // 아래의 예외 상황에서는 데이터를 불러오지 않음:
            // 1. 페이지가 1인 경우 = 초기 로드 (selectedArea didSet에서 처리)
            // 2. page 변경 전후의 값이 같은 경우 = 무한스크롤 중복 트리거 방지
            guard page != 1, oldValue != page else { return }
                Task {
                    await fetchPlaceList()
                }
        }
    }

    /// API에서 제공하는 전체 여행지 수 (페이지네이션 계산용)
    var totalCount: Int = 0
    /// 한 페이지당 요청할 여행지 수
    let numOfRows = 40
    /// 데이터 fetch 상태 플래그
    var isLoading = false
    
    var plannerTitle: String? = nil
    var titleBinding: Binding<String> {
        Binding(
            get: {
                if let planner = self.planner {
                    return planner.title
                } else {
                    return self.plannerTitle ?? ""
                }
            },
            set: { newValue in
                self.plannerTitle = newValue.isEmpty ? nil : newValue
            }
        )
    }
    
    var selectedImage: UIImage? = nil
    var imageBinding: Binding<UIImage> {
        Binding(
            get: { self.selectedImage ?? UIImage() },
            set: { newValue in
                self.selectedImage = newValue
            }
        )
    }
    var placeList: [PlaceDTO] = []
    
    var planner: PlannerDTO? = nil

    deinit {
        print(self, #function)
    }
    
    /// 선택된 지역의 여행지 목록을 API로부터 가져오는 함수
    @MainActor
    func fetchPlaceList() async {
        defer { isLoading = false }
        
        guard !isLoading, let area = selectedArea else { return }
        
        isLoading = true
        do {
            // API 요청 및 응답 유효성 검증
            guard let body = try await placeRepository.fetchPlaceList(endpoint: AreaBasedEndpoint(page: page, numOfRows: numOfRows, area: area)),
                  body.totalCount > 0 else { return }
            
            totalCount = body.totalCount
            
            // 페이지가 1이 아닐 경우 기존 목록에 추가
            if placeList.isEmpty {
                placeList = body.items.content
            } else {
                placeList.append(contentsOf: body.items.content)
            }
        } catch {
            print(#function, "🔥 \(area.fullName) 지역에 장소가 없음")
        }
    }
    
    func savePlanner(placeList: [PlaceDTO]) async {
        var newPlanner: PlannerDTO
        
        var plannerPlaceList = [PlannerPlaceDTO]()
        
        for index in 0 ... (placeList.count - 1) {
            let place = placeList[index]
            plannerPlaceList.append(
                place.toPlannerPlaceDTO(with: index)
            )
        }
        
        if let planner {
            // 기존 여행을 편집할 때
            newPlanner = PlannerDTO(
                id: planner.id,
                title: plannerTitle ?? planner.title,
                startDate: planner.startDate,
                endDate: planner.endDate,
                thumbnail: nil, // TODO: ImageManager 적용하기
                placeList: plannerPlaceList
            )
        } else {
            // 새로운 여행일 때
            guard let plannerTitle else { return }
            let now = Date.now
            
            newPlanner = PlannerDTO(
                id: UUID(),
                title: plannerTitle,
                startDate: now,
                endDate: now,
                thumbnail: nil, // TODO: ImageManager 적용하기
                placeList: plannerPlaceList
            )
        }
        
        do {
            try await plannerRepository.upsertPlanner(newPlanner, places: newPlanner.placeList)
        } catch {
            print(error)
        }
    }
}
