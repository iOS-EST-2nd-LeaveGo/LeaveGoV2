//
//  Planner+Extension.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/14/25.
//

import Foundation

extension Planner {
    func toPlannerDTO() -> PlannerDTO {
        let placeList = (self.places?.allObjects as? [PlannerPlace])?
            .sorted { $0.order < $1.order }
            .map { place in
                place.toPlannerPlaceDTO()
            } ?? []
        
        return PlannerDTO(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            startDate: self.startDate ?? Date(),
            endDate: self.endDate ?? Date(),
            thumbnail: self.thumbnail,
            placeList: placeList
        )
    }
}
