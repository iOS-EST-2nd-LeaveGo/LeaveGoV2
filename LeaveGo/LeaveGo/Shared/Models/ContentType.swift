//
//  ContentType.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/7/25.
//

import Foundation

/// 한국관광공사 API의 콘텐츠 타입을 정의하는 열거형
/// 각 케이스는 API에서 사용하는 고유 번호와 매핑됨
enum ContentType: String, CaseIterable, Equatable {
    /// 관광지 (타입 고유번호: 12)
    case touristAttraction = "12"

    /// 문화시설 (타입 고유번호: 14)
    case cultureFacility = "14"

    /// 레저스포츠 (타입 고유번호: 28)
    case leisureSports = "28"

    /// 쇼핑 (타입 고유번호: 38)
    case shopping = "38"

    /// 음식점 (타입 고유번호: 39)
    case restaurant = "39"
}
