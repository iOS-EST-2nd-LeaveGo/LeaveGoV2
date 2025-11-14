//
//  PlaceDTO.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import Foundation

/// 장소 기본 정보를 담는 데이터 전송 객체
/// 한국관광공사 API의 지역기반관광정보조회 및 위치기반관광정보조회에서 사용
struct PlaceDTO: Codable, Hashable, Identifiable {
    /// 주소
    let addr1: String?
    /// 상세주소
    let addr2: String?
    /// 지역코드
    let areaCode: String?
    /// 대분류코드
    let cat1: String?
    /// 중분류코드
    let cat2: String?
    /// 소분류코드
    let cat3: String?
    /// 장소 고유번호
    let id: String
    /// 장소 관광지 타입
    let contentTypeID: String
    /// 중심 좌표로부터의 거리
    let dist: String?
    /// 썸네일이미지
    let bigThumbnailImage: String?
    /// 썸네일이미지
    let thumbnailImage: String?
    /// 경도
    let mapX: String?
    /// 위도
    let mapY: String?
    /// 전화번호
    let tel: String?
    /// 장소명
    let title: String

    /// JSON 키 매핑을 위한 CodingKeys
    /// API 응답의 키명과 Swift 프로퍼티명을 매핑
    enum CodingKeys: String, CodingKey {
        case addr1
        case addr2
        case areaCode = "areacode"
        case cat1
        case cat2
        case cat3
        case id = "contentid"
        case contentTypeID = "contenttypeid"
        case dist
        /// 카드 UI 에 사용할 큰 썸네일 이미지
        case bigThumbnailImage = "firstimage"
        /// 썸네일용 이미지는 firstimage2 에 담겨오는데 이름이 직관적이지 않아서 변경
        case thumbnailImage = "firstimage2"
        case mapX = "mapx"
        case mapY = "mapy"
        case tel
        case title
    }
}

extension PlaceDTO {
    func toPlannerPlaceDTO(with order: Int) -> PlannerPlaceDTO {
        return PlannerPlaceDTO(
            id: UUID(),
            title: self.title,
            contentID: self.id,
            thumbnail: self.thumbnailImage,
            date: Date(),
            order: Int16(order)
        )
    }
}

