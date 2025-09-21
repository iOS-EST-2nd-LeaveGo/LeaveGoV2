//
//  PlannerPlaceListDTO.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/14/25.
//

import Foundation

struct PlannerPlaceListDTO {
    let area: Area
    let places: [PlannerPlace?]
    
    struct PlannerPlace {
        let title: String
        let contentId: Int
        let contentTypeId: Int?
        
        init(title: String, contentId: Int, contentTypeId: Int?) {
            self.title = title
            self.contentId = contentId
            self.contentTypeId = contentTypeId
        }
    }
    
    init(area: Area, places: [PlannerPlace?]) {
        self.area = area
        self.places = places
    }
}
