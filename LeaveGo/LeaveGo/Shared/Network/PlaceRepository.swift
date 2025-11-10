//
//  PlaceRepository.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/4/25.
//

import SwiftUI

final class PlaceRepository {
    private let networkManager: NetworkService
    
    init(networkManager: NetworkService = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func fetchPlaceList(with endpoint: Endpoint) async throws -> (placeList: [PlaceDTO], totalCount: Int)? {
        do {
            let rawData = try await networkManager.fetch(from: endpoint)
            
            if let data = try networkManager.decode(data: rawData, type: TourResponseRoot<PlaceDTO>.self) {
                if data.response.body.totalCount != 0 {
                    return (
                        placeList: data.response.body.items.content,
                        totalCount: data.response.body.totalCount
                    )
                } else {
                    print("🔥 검색된 장소가 없음")
                }
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func fetchPlaceDetail(with endpoint: PlaceDetailEndpoint) async throws -> PlaceDetailDTO? {
        do {
            let rawData = try await networkManager.fetch(from: endpoint)
            
            if let data = try networkManager.decode(data: rawData, type: TourResponseRoot<PlaceDetailDTO>.self) {
                if data.response.body.totalCount != 0,
                   let placeDetail = data.response.body.items.content.first {
                    return placeDetail.htmlCleaned()
                } else {
                    print("🔥 contentTypeID \(endpoint.contentType.rawValue), contentID \(endpoint.contentID)에 해당하는 장소를 찾을 수 없음")
                }
            }
        } catch {
            print(error)
        }
        return nil
    }
}
