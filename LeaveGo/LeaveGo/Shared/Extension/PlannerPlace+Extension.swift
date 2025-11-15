//
//  PlannerPlace+Extension.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/14/25.
//

import Foundation

extension PlannerPlace {
    func toPlannerPlaceDTO() -> PlannerPlaceDTO {
        return PlannerPlaceDTO(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            contentID: self.contentID ?? "",
            contentTypeID: self.contentTypeID ?? "",
            thumbnail: self.thumbnail,
            date: self.date ?? Date.now,
            order: self.order
        )
    }
}
