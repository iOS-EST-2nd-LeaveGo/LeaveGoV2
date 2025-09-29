//
//  PlannerDTO.swift
//  LeaveGo
//
//  Created by 박동언 on 9/21/25.
//

import Foundation

struct PlannerDTO: Identifiable {
    let id: UUID
    let title: String?
    let startDate: Date
    let endDate: Date
    let thumbnail: String?
    let placeList: [PlannerPlaceListDTO]?
}

// 더미 데이터
let mockPlanners = [
    PlannerDTO(id: UUID(), title: "👒 모두 다함께 광화문 여행을 떠나봅시다", startDate: Date(), endDate: Date(), thumbnail: "02", placeList: nil),
    PlannerDTO(id: UUID(), title: "🌊 부산 여행", startDate: Date(), endDate: Date(), thumbnail: nil, placeList: nil),
    PlannerDTO(id: UUID(), title: "🚀 우주 여행 ✨", startDate: Date(), endDate: Date(), thumbnail: nil, placeList: nil)
]

/*
extension Planner {
    convenience init?(entity: PlannerEntity) {
        guard let title = entity.title else { return nil }

        let id = entity.id ?? UUID() // ✅ entity에서 ID를 가져오거나 UUID 생성
        let placeModels: [PlannerPlaceListDTO]? = nil

        self.init(id: id, title: title, thumbnailPath: entity.thumbnailPath, placeList: placeModels)
    }
}
*/
