//
//  TourResponse.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/1/25.
//

import Foundation

/// API 응답의 최상위 래퍼 구조체
/// - Parameter T: 실제 데이터 타입
struct TourResponseRoot<T: Decodable>: Decodable {
    /// API 응답 내용
    let response: TourResponse<T>
}

/// API 응답의 기본 구조체
/// - Parameter T: 실제 데이터 타입
struct TourResponse<T: Decodable>: Decodable {
    /// 응답 헤더 (결과 코드, 메시지)
    let header: TourResponseHeader
    /// 응답 본문 (실제 데이터)
    let body: TourResponseBody<T>
}

/// API 응답 헤더 정보
struct TourResponseHeader: Decodable {
    /// 결과 코드
    let resultCode: String
    /// 결과 메시지
    let resultMsg: String
}

/// API 응답 본문 구조체
/// - Parameter T: 실제 데이터 타입
struct TourResponseBody<T: Decodable>: Decodable {
    /// 데이터 아이템들
    let items: TourContent<T>
    /// 페이지당 행 수
    let numOfRows: Int
    /// 페이지 번호
    let pageNo: Int
    /// 총 데이터 개수
    let totalCount: Int
}

/// 실제 콘텐츠 데이터를 담는 컨테이너 구조체
/// - Parameter T: 실제 데이터 타입
/// - Note: API에서 빈 문자열("")이나 배열 형태로 올 수 있는 응답을 처리
struct TourContent<T: Decodable>: Decodable {
    /// 실제 데이터 배열
    let content: [T]

    /// 커스텀 디코딩 초기화
    /// API 응답에서 빈 문자열이나 정상 배열을 모두 처리
    /// - Parameter decoder: JSON 디코더
    /// - Throws: 디코딩 에러
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

    /// 직접 초기화 메서드
    /// - Parameter content: 초기화할 데이터 배열
    init(content: [T]) {
        self.content = content
    }

    /// JSON 키 매핑
    enum CodingKeys: String, CodingKey {
        case content = "item"
    }
}
