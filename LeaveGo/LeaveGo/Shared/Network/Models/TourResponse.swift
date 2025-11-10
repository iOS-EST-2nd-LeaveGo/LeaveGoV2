//
//  TourResponse.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/1/25.
//

import Foundation

struct TourResponseRoot<T: Decodable>: Decodable {
    let response: TourResponse<T>
}

struct TourResponse<T: Decodable>: Decodable {
    let header: TourResponseHeader
    let body: TourResponseBody<T>
}

struct TourResponseHeader: Decodable {
    let resultCode: String
    let resultMsg: String
}

struct TourResponseBody<T: Decodable>: Decodable {
    let items: TourContent<T>
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct TourContent<T: Decodable>: Decodable {
    let content: [T]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // items가 "" 빈 문자열이면 빈 배열로 초기화
        if let _ = try? container.decode(String.self) {
            self.content = []
        } else {
            // 정상적으로 디코딩 가능한 경우
            let object = try container.decode([String: [T]].self)
            self.content = object["item"] ?? []
        }
    }

    init(content: [T]) {
        self.content = content
    }
    
    enum CodingKeys: String, CodingKey {
        case content = "item"
    }
}
