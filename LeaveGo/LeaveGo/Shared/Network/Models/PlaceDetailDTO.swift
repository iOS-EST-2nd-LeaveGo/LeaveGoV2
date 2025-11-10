//
//  PlaceDetailDTO.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/10/25.
//

import Foundation

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
    
    var contentType: ContentType {
        switch contentTypeID {
        case "12": .touristAttraction
        case "14": .cultureFacility
        case "28": .leisureSports
        case "38": .shopping
        case "39": .restaurant
        default: .touristAttraction
        }
    }
    
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
    
    func htmlCleaned() -> PlaceDetailDTO {
        var copy = self
        copy.infoCenter = infoCenter?.htmlToPlainText
        copy.openTime = openTime?.htmlToPlainText
        copy.restDate = restDate?.htmlToPlainText
        return copy
    }
}
