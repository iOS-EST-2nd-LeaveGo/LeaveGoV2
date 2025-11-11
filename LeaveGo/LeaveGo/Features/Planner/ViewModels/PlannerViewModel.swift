//
//  PlannerViewModel.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/11/25.
//

import Foundation
import SwiftUI

@Observable
final class PlannerViewModel {
    let repository = PlaceRepository()
    
    var placeList: [PlaceDTO] = []
    
    var pageNo = 1
    let numOfRows = 40
    
    func fetchPlaceList(of area: Area) async {
        do {
            guard let body = try await repository.fetchPlaceList(endpoint: AreaBasedEndpoint(page: pageNo, numOfRows: numOfRows, area: area)),
            body.totalCount > 0 else { return }
            placeList = body.items.content
        } catch {
            print("🔥 \(area.fullName) 지역에 장소가 없음")
        }
    }
}
