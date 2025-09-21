//
//  Place.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/13/25.
//

import Foundation

struct Place: Codable, Hashable, Identifiable {
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
    let contentTypeId: String
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
    
    enum CodingKeys: String, CodingKey {
        case addr1
        case addr2
        case areaCode = "areacode"
        case cat1
        case cat2
        case cat3
        case id = "contentid"
        case contentTypeId = "contenttypeid"
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

let mockPlace1 = Place(
    addr1: nil,
    addr2: nil,
    areaCode: nil,
    cat1: "A01",
    cat2: nil,
    cat3: nil,
    id: "11",
    contentTypeId: "11",
    dist: nil,
    bigThumbnailImage: nil,
    thumbnailImage: nil,
    mapX: nil,
    mapY: nil,
    tel: nil,
    title: "광화문"
)

let mockPlace2 = Place(
    addr1: nil,
    addr2: nil,
    areaCode: nil,
    cat1: "A02",
    cat2: nil,
    cat3: nil,
    id: "12",
    contentTypeId: "11",
    dist: nil,
    bigThumbnailImage: nil,
    thumbnailImage: nil,
    mapX: nil,
    mapY: nil,
    tel: nil,
    title: "광화문2"
)

let mockPlaceArray: [Place] = [mockPlace1, mockPlace2, mockPlace3, mockPlace4, mockPlace5, mockPlace6, mockPlace7, mockPlace8]

let mockPlace3 = Place(
    addr1: nil,
    addr2: nil,
    areaCode: nil,
    cat1: "A01",
    cat2: nil,
    cat3: nil,
    id: "13",
    contentTypeId: "11",
    dist: nil,
    bigThumbnailImage: nil,
    thumbnailImage: nil,
    mapX: nil,
    mapY: nil,
    tel: nil,
    title: "광화문3"
)

let mockPlace4 = Place(
    addr1: nil,
    addr2: nil,
    areaCode: nil,
    cat1: "A02",
    cat2: nil,
    cat3: nil,
    id: "14",
    contentTypeId: "11",
    dist: nil,
    bigThumbnailImage: nil,
    thumbnailImage: nil,
    mapX: nil,
    mapY: nil,
    tel: nil,
    title: "광화문4"
)

let mockPlace5 = Place(
    addr1: nil,
    addr2: nil,
    areaCode: nil,
    cat1: "A01",
    cat2: nil,
    cat3: nil,
    id: "15",
    contentTypeId: "11",
    dist: nil,
    bigThumbnailImage: nil,
    thumbnailImage: nil,
    mapX: nil,
    mapY: nil,
    tel: nil,
    title: "광화문5"
)

let mockPlace6 = Place(
    addr1: nil,
    addr2: nil,
    areaCode: nil,
    cat1: "A02",
    cat2: nil,
    cat3: nil,
    id: "16",
    contentTypeId: "11",
    dist: nil,
    bigThumbnailImage: nil,
    thumbnailImage: nil,
    mapX: nil,
    mapY: nil,
    tel: nil,
    title: "광화문6"
)

let mockPlace7 = Place(
    addr1: nil,
    addr2: nil,
    areaCode: nil,
    cat1: "A01",
    cat2: nil,
    cat3: nil,
    id: "17",
    contentTypeId: "11",
    dist: nil,
    bigThumbnailImage: nil,
    thumbnailImage: nil,
    mapX: nil,
    mapY: nil,
    tel: nil,
    title: "광화문7"
)

let mockPlace8 = Place(
    addr1: nil,
    addr2: nil,
    areaCode: nil,
    cat1: "A02",
    cat2: nil,
    cat3: nil,
    id: "18",
    contentTypeId: "11",
    dist: nil,
    bigThumbnailImage: nil,
    thumbnailImage: nil,
    mapX: nil,
    mapY: nil,
    tel: nil,
    title: "광화문8"
)
