//
//  PlaceRepository.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/4/25.
//

import Foundation

/// 장소 관련 데이터 접근을 담당하는 Repository 클래스
final class PlaceRepository {
    /// 네트워크 통신을 담당하는 서비스
    private let networkManager: NetworkService

    /// PlaceRepository 초기화
    /// - Parameter networkManager: 네트워크 서비스 인스턴스 (기본값: NetworkManager.shared)
    init(networkManager: NetworkService = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    /// 장소 목록을 가져오는 메서드
    /// - Parameter endpoint: API 엔드포인트 정보
    /// - Returns: 장소 목록과 총 개수를 포함한 튜플, 데이터가 없으면 nil
    /// - Throws: 네트워크 에러
    func fetchPlaceList(endpoint: Endpoint) async throws -> TourResponseBody<PlaceDTO>? {
        let rawData = try await networkManager.fetch(from: endpoint)

        let data = try networkManager.decode(data: rawData, type: TourResponseRoot<PlaceDTO>.self)
        if data.response.body.totalCount != 0 {
            return data.response.body
        } else {
            print("🔥 검색된 장소가 없음")
            return nil
        }
    }
    
    /// 특정 장소의 상세 정보를 가져오는 메서드
    /// - Parameter endpoint: 장소 상세 정보 API 엔드포인트
    /// - Returns: 장소 상세 정보 DTO, 데이터가 없으면 nil
    /// - Throws: 네트워크 에러
    func fetchPlaceDetail(endpoint: PlaceDetailEndpoint) async throws -> PlaceDetailDTO? {
        let rawData = try await networkManager.fetch(from: endpoint)

        let data = try networkManager.decode(data: rawData, type: TourResponseRoot<PlaceDetailDTO>.self)
        if data.response.body.totalCount != 0,
           let placeDetail = data.response.body.items.content.first {
            return await placeDetail.htmlCleaned()
        } else {
            print("🔥 contentTypeID \(endpoint.contentType.rawValue), contentID \(endpoint.contentID)에 해당하는 장소를 찾을 수 없음")
            return nil
        }
    }
}
