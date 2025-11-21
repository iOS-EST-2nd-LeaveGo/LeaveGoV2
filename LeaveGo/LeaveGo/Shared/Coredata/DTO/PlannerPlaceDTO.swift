//
//  PlaceDTO.swift
//  LeaveGo
//
//  Created by 박동언 on 9/21/25.
//

import Foundation

struct PlannerPlaceDTO: Hashable {
    let id: UUID
    let title: String
    let contentID: String
    let contentTypeID: String
    let thumbnail: String?
    let date: Date
    let order: Int16
}

extension PlannerPlaceDTO {
    func toPlaceDTO() -> PlaceDTO {
        return PlaceDTO(
            addr1: nil,
            addr2: nil,
            areaCode: nil,
            cat1: nil,
            cat2: nil,
            cat3: nil,
            id: self.contentID,
            contentTypeID: self.contentTypeID,
            dist: nil,
            bigThumbnailImage: nil,
            thumbnailImage: self.thumbnail,
            mapX: nil,
            mapY: nil,
            tel: nil,
            title: self.title
        )
    }
}
