//
//  PlaceDetailDTO.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/10/25.
//

import Foundation

/// 장소 상세 정보를 담는 데이터 전송 객체
/// - Note: 다양한 ContentType(관광지, 문화시설, 레저스포츠, 쇼핑, 음식점)의 데이터를 통합 처리
struct PlaceDetailDTO: Decodable {
    /// 장소 고유번호
    let contentID: String
    /// 장소 관광지 타입
    let contentTypeID: String
    /// 주차 가능여부
    var parking: String?
    /// 안내센터명 또는 전화번호
    var infoCenter: String?
    /// 운영시간
    var openTime: String?
    /// 연중무휴 여부
    var restDate: String?
    /// 관람 소요시간
    let duration: String?
    /// 놀이방 여부
    let kidsFacility: String?

    /// contentTypeID 문자열을 ContentType enum으로 변환하는 계산 프로퍼티
    /// - Returns: 해당하는 ContentType, 알 수 없는 타입은 .touristAttraction으로 기본값 처리
    var contentType: ContentType {
        switch contentTypeID {
        case "12": return .touristAttraction
        case "14": return .cultureFacility
        case "28": return .leisureSports
        case "38": return .shopping
        case "39": return .restaurant
        default: return .touristAttraction
        }
    }

    /// JSON 키 매핑을 위한 CodingKeys
    /// ContentType별로 서로 다른 API 키들을 정의
    enum CodingKeys: String, CodingKey {
        case contentTypeID = "contenttypeid"
        case contentID = "contentid"

        // 공통 키
        case infoCenter = "infocenter"
        case openTime = "usetime"
        case restDate = "restdate"
        case duration = "spendtime"
        case kidsFacility = "kidsfacility"

        // ContentType별 다른 키들
        case infoCenterCulture = "infocenterculture"
        case infoCenterLeports = "infocenterleports"
        case infoCenterShopping = "infocentershopping"
        case infoCenterFood = "infocenterfood"

        case useTimeCulture = "usetimeculture"
        case useTimeLeports = "usetimeleports"
        case openTimeFood = "opentimefood"

        case restDateCulture = "restdateculture"
        case restDateLeports = "restdateleports"
        case restDateShopping = "restdateshopping"
        case restDateFood = "restdatefood"

        //case openPeriod = "openperiod"
        //case fairDay = "fairday"
        case openTimeShopping = "opentime"
        
        case parking
        case parkingCulture = "parkingculture"
        case parkingLeports = "parkingleports"
        case parkingShopping = "parkingshopping"
        case parkingFood = "parkingfood"
    }

    /// 커스텀 디코딩 초기화
    /// ContentType에 따라 다른 JSON 키에서 데이터를 가져와 통합된 프로퍼티에 할당
    /// - Parameter decoder: JSON 디코더
    /// - Throws: 디코딩 에러
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        contentID = try container.decode(String.self, forKey: .contentID)
        contentTypeID = try container.decode(String.self, forKey: .contentTypeID)
        duration = try container.decodeIfPresent(String.self, forKey: .duration)
        kidsFacility = try container.decodeIfPresent(String.self, forKey: .kidsFacility)

        // ContentType에 따라 다른 키에서 데이터 가져오기
        switch contentTypeID {
        case "12": // 관광지
            parking = try container.decodeIfPresent(String.self, forKey: .parking)
            infoCenter = try container.decodeIfPresent(String.self, forKey: .infoCenter)
            openTime = try container.decodeIfPresent(String.self, forKey: .openTime)
            restDate = try container.decodeIfPresent(String.self, forKey: .restDate)
            parking = try container.decodeIfPresent(String.self, forKey: .parking)

        case "14": // 문화시설
            parking = try container.decodeIfPresent(String.self, forKey: .parkingCulture)
            infoCenter = try container.decodeIfPresent(String.self, forKey: .infoCenterCulture)
            openTime = try container.decodeIfPresent(String.self, forKey: .useTimeCulture)
            restDate = try container.decodeIfPresent(String.self, forKey: .restDateCulture)
            parking = try container.decodeIfPresent(String.self, forKey: .parkingCulture)

        case "28": // 레저스포츠
            parking = try container.decodeIfPresent(String.self, forKey: .parking)
            infoCenter = try container.decodeIfPresent(String.self, forKey: .infoCenterLeports)
            openTime = try container.decodeIfPresent(String.self, forKey: .useTimeLeports)
            restDate = try container.decodeIfPresent(String.self, forKey: .restDateLeports)
            parking = try container.decodeIfPresent(String.self, forKey: .parkingLeports)

        case "38": // 쇼핑
            infoCenter = try container.decodeIfPresent(String.self, forKey: .infoCenterShopping)
            openTime = try container.decodeIfPresent(String.self, forKey: .openTimeShopping)
            restDate = try container.decodeIfPresent(String.self, forKey: .restDateShopping)
            //openDate = try container.decodeIfPresent(String.self, forKey: .fairDay)
            parking = try container.decodeIfPresent(String.self, forKey: .parkingShopping)

        case "39": // 음식점
            parking = try container.decodeIfPresent(String.self, forKey: .parking)
            infoCenter = try container.decodeIfPresent(String.self, forKey: .infoCenterFood)
            openTime = try container.decodeIfPresent(String.self, forKey: .openTimeFood)
            restDate = try container.decodeIfPresent(String.self, forKey: .restDateFood)
            parking = try container.decodeIfPresent(String.self, forKey: .parkingFood)

        default:
            infoCenter = try container.decodeIfPresent(String.self, forKey: .infoCenter)
            openTime = try container.decodeIfPresent(String.self, forKey: .openTime)
            restDate = try container.decodeIfPresent(String.self, forKey: .restDate)
            parking = try container.decodeIfPresent(String.self, forKey: .parking)
        }
    }

    /// HTML 태그를 제거한 정제된 PlaceDetailDTO를 반환
    /// infoCenter, openTime, restDate 필드의 HTML 태그를 평문으로 변환
    /// - Returns: HTML 태그가 제거된 PlaceDetailDTO 복사본
    func htmlCleaned() async -> PlaceDetailDTO {
        var copy = self

        copy.infoCenter = await infoCenter?.htmlToPlainText()
        copy.openTime = await openTime?.htmlToPlainText()
        copy.restDate = await restDate?.htmlToPlainText()

        return copy
    }
}
