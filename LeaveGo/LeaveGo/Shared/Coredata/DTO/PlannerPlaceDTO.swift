//
//  PlaceDTO.swift
//  LeaveGo
//
//  Created by 박동언 on 9/21/25.
//

import Foundation

struct PlannerPlaceDTO {
    let id: UUID
    let title: String
    let contentID: String
    let thumbnail: String?
    let date: Date
    let order: Int16
}

