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
    
    var selectedArea: Area? {
        didSet {
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
    
    var page: Int = 1 {
        didSet {
            guard page != 1, oldValue != page else { return }
                Task {
                    await fetchPlaceList()
                }
        }
    }
    
    var totalCount: Int = 0
    let numOfRows = 40
    
    deinit {
        print(self, #function)
    }
    
    @MainActor
    func fetchPlaceList() async {
        guard let area = selectedArea else { return }
        do {
            guard let body = try await repository.fetchPlaceList(endpoint: AreaBasedEndpoint(page: page, numOfRows: numOfRows, area: area)),
            body.totalCount > 0 else { return }
            
            totalCount = body.totalCount
            if placeList.isEmpty {
                placeList = body.items.content
            } else {
                placeList.append(contentsOf: body.items.content)
            }
        } catch {
            print(#function, "🔥 \(area.fullName) 지역에 장소가 없음")
        }
    }
}
