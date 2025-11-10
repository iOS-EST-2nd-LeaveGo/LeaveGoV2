//
//  ContentType.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/7/25.
//

import Foundation

enum ContentType: String, CaseIterable, Equatable {
    /// 관광 : 12
    case touristAttraction = "12"
    /// 문화시설 : 14
    case cultureFacility = "14"
    /// 레포츠 : 28
    case leisureSports = "28"
    /// 쇼핑 : 38
    case shopping = "38"
    /// 음식점 : 39
    case restaurant = "39"
}
