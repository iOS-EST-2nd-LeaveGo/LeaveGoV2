//
//  PlaceDetail.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 6/9/25.
//

import Foundation

// MARK: - 장소 상세 정보 공통 인터페이스 정의
/// 관광지, 음식점, 쇼핑 등 다양한 유형의 장소 상세 데이터를 공통 처리하기 위한 프로토콜
protocol PlaceDetailProtocol {
    /// HTML 태그 제거 또는 정제 처리된 데이터를 반환
    func htmlCleaned() -> Self
}

/// 관광지
struct PlaceDetail12: Codable, PlaceDetailProtocol {
    /// 장소 고유번호
    let contentId: String
    /// 장소 관광지 타입
    let contentTypeId: String
    /// 주차 가능여부
    let parking: String?
    /// 안내센터명 또는 전화번호
    var infoCenter: String?
    /// 운영요일
    let openDate: String?
    /// 운영시간
    var openTime: String?
    /// 연중무휴 여부
    var restDate: String?

    enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case parking
        case infoCenter = "infocenter"
        case openDate = "opendate"
        case openTime = "usetime"
        case restDate = "restdate"
    }

    func htmlCleaned() -> PlaceDetail12 {
        var copy = self
        copy.infoCenter = infoCenter?.htmlToPlainText
        copy.openTime = openTime?.htmlToPlainText
        copy.restDate = restDate?.htmlToPlainText
        return copy
    }
}

/// 문화시설
struct PlaceDetail14: Codable, PlaceDetailProtocol {
    var openDate: String?
    /// 장소 고유번호
    let contentId: String
    /// 장소 관광지 타입
    let contentTypeId: String
    /// 주차 가능여부
    let parking: String?
    var infoCenter: String?
    /// 운영시간
    var openTime: String?
    /// 연중무휴 여부
    var restDate: String?
    /// 관람 소요시간
    let duration: String?
    
    enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case parking = "parkingculture"
        case infoCenter = "infocenterculture"
        case openTime = "usetimeculture"
        case restDate = "restdateculture"
        case duration = "spendtime"
    }

    func htmlCleaned() -> PlaceDetail14 {
        var copy = self
        copy.infoCenter = infoCenter?.htmlToPlainText
        copy.openTime = openTime?.htmlToPlainText
        copy.restDate = restDate?.htmlToPlainText
        return copy
    }
}

/// 레포츠
struct PlaceDetail28: Codable, PlaceDetailProtocol {
    /// 장소 고유번호
    let contentId: String
    /// 장소 관광지 타입
    let contentTypeId: String
    /// 주차 가능여부
    let parking: String?
    /// 안내센터명 또는 전화번호
    var infoCenter: String?
    /// 운영요일
    let openDate: String?
    /// 운영시간
    var openTime: String?
    /// 연중무휴 여부
    var restDate: String?

    enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case parking = "parkingleports"
        case infoCenter = "infocenterleports"
        case openDate = "openperiod"
        case openTime = "usetimeleports"
        case restDate = "restdateleports"
    }

    func htmlCleaned() -> PlaceDetail28 {
        var copy = self
        copy.infoCenter = infoCenter?.htmlToPlainText
        copy.openTime = openTime?.htmlToPlainText
        copy.restDate = restDate?.htmlToPlainText
        return copy
    }
}

/// 쇼핑
struct PlaceDetail38: Codable, PlaceDetailProtocol {
    /// 장소 고유번호
    let contentId: String
    /// 장소 관광지 타입
    let contentTypeId: String
    /// 주차 가능여부
    let parking: String?
    /// 안내센터명 또는 전화번호
    var infoCenter: String?
    /// 운영요일
    let openDate: String?
    /// 운영시간
    var openTime: String?
    /// 연중무휴 여부
    var restDate: String?
    
    enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case parking = "parkingshopping"
        case infoCenter = "infocentershopping"
        case openDate = "fairday"
        case openTime = "opentime"
        case restDate = "restdateshopping"
    }

    func htmlCleaned() -> PlaceDetail38 {
        var copy = self
        copy.infoCenter = infoCenter?.htmlToPlainText
        copy.openTime = openTime?.htmlToPlainText
        copy.restDate = restDate?.htmlToPlainText
        return copy
    }
}

/// 음식점
struct PlaceDetail39: Codable, PlaceDetailProtocol {
    /// 장소 고유번호
    let contentId: String
    /// 장소 관광지 타입
    let contentTypeId: String
    /// 놀이방 여부
    let kidsFacility: String?
    /// 주차 가능여부
    let parking: String?
    /// 안내센터명 또는 전화번호
    var infoCenter: String?
    /// 운영요일
    let openDate: String?
    /// 운영시간
    var openTime: String?
    /// 연중무휴 여부
    var restDate: String?
    
    enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case kidsFacility = "kidsfacility"
        case parking
        case infoCenter = "infocenterfood"
        case openDate = "opendatefood"
        case openTime = "opentimefood"
        case restDate = "restdatefood"
    }

    func htmlCleaned() -> PlaceDetail39 {
        var copy = self
        copy.infoCenter = infoCenter?.htmlToPlainText
        copy.openTime = openTime?.htmlToPlainText
        copy.restDate = restDate?.htmlToPlainText
        return copy
    }
}
