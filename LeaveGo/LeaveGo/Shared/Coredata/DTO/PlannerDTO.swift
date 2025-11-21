//
//  PlannerDTO.swift
//  LeaveGo
//
//  Created by 박동언 on 9/21/25.
//

import Foundation

struct PlannerDTO: Identifiable, Hashable {
    let id: UUID
    let title: String
    let startDate: Date
    let endDate: Date
    let thumbnail: String?
    let placeList: [PlannerPlaceDTO]
}
