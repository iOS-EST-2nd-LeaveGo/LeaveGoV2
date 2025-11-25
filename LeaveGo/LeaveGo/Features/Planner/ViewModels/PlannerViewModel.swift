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
    /// 여행 데이터 CoreData 처리를 담당하는 리포지토리
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
    
    /// 입력 중인 여행 제목 (새 여행 생성 시 사용)
    var plannerTitle: String? = nil
    /// 여행 제목 입력 필드를 위한 바인딩
    /// - 생성 모드: plannerTitle 반환
    /// - 수정 모드: 기존 planner.title 반환
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
    
    /// 선택된 썸네일 이미지 (PhotosPicker에서 선택)
    var selectedImage: UIImage? = nil
    /// 이미지 선택을 위한 바인딩
    var imageBinding: Binding<UIImage> {
        Binding(
            get: { self.selectedImage ?? UIImage() },
            set: { newValue in
                self.selectedImage = newValue
            }
        )
    }
    
    /// 여행지 재선택 시트의 열림/닫힘 상태
    var shouldOpenSheet: Bool = false
    /// 시트 상태 관리를 위한 바인딩
    var sheetStatusBinding: Binding<Bool> {
        Binding(
            get: { self.shouldOpenSheet },
            set: { newValue in
                self.shouldOpenSheet = newValue
            }
        )
    }
    
    /// 현재 수정 중인 여행 데이터 (수정 모드에서만 사용)
    var planner: PlannerDTO? = nil
    
    /// 여행지 목록을 담는 변수들
    /// API에서 가져온 여행지 목록: 여행 생성 + 수정 시
    var placeList: [PlaceDTO] = []
    /// 여행 수정 시 수정된 여행지 목록
    var modifiedPlaceList: [PlaceDTO] = []
    
    /// 여행 신규 생성 시 네비게이션 조작을 위한 변수
    var navigationPath: Binding<NavigationPath>?
    
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
    
    /// 여행을 CoreData에 저장 (생성 + 수정)
    /// - Parameter placeList: 저장할 여행지 목록
    func savePlanner(placeList: [PlaceDTO]) async {
        var newPlanner: PlannerDTO
        
        // PlaceDTO를 PlannerPlaceDTO로 변환하며 순서(order) 정보 추가
        var plannerPlaceList = [PlannerPlaceDTO]()
        for index in 0 ..< placeList.count {
            let place = placeList[index]
            plannerPlaceList.append(
                place.toPlannerPlaceDTO(with: index)
            )
        }
        
        if let planner {
            // 기존 여행 수정: 기존 ID와 날짜 유지, 제목과 여행지만 업데이트
            newPlanner = PlannerDTO(
                id: planner.id,
                title: plannerTitle ?? planner.title,
                startDate: planner.startDate,
                endDate: planner.endDate,
                thumbnail: nil, // TODO: ImageManager 적용하기
                placeList: plannerPlaceList
            )
        } else {
            // 새 여행 생성: 새로운 ID 생성, 현재 날짜로 설정
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
        
        // CoreData에 저장 (upsert: 기존 데이터가 있으면 업데이트, 없으면 생성)
        do {
            try await plannerRepository.upsertPlanner(newPlanner, places: newPlanner.placeList)
        } catch {
            print(error)
        }
    }
}
