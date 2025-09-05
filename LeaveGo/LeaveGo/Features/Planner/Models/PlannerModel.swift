//
//  PlannerModel.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/5/25.
//

import Foundation

class Planner: Identifiable {
    let id: UUID
    let title: String
    let thumbnailPath: String?
    let placeList: [PlannerPlaceListModel]?
    
    init(id: UUID, title: String, thumbnailPath: String?, placeList: [PlannerPlaceListModel]?) {
        self.id = id
        self.title = title
        self.thumbnailPath = thumbnailPath
        self.placeList = placeList
    }
}

// 더미 데이터
let mockPlanners = [
    Planner(id: UUID(), title: "👒 모두 다함께 광화문 여행을 떠나봅시다", thumbnailPath: nil, placeList: nil),
    Planner(id: UUID(), title: "🌊 부산 여행", thumbnailPath: nil, placeList: nil),
    Planner(id: UUID(), title: "🚀 우주 여행 ✨", thumbnailPath: nil, placeList: nil)
]

/*
extension Planner {
    convenience init?(entity: PlannerEntity) {
        guard let title = entity.title else { return nil }
        
        let id = entity.id ?? UUID() // ✅ entity에서 ID를 가져오거나 UUID 생성
        let placeModels: [PlannerPlaceListModel]? = nil

        self.init(id: id, title: title, thumbnailPath: entity.thumbnailPath, placeList: placeModels)
    }
}
*/
