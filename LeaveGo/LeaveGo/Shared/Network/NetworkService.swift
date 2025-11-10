//
//  NetworkService.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/29/25.
//

import Foundation

/// 네트워크 통신을 위한 서비스 프로토콜
protocol NetworkService {
    /// 주어진 엔드포인트에서 데이터를 가져오는 메서드
    /// - Parameter endpoint: API 엔드포인트 정보
    /// - Returns: 서버에서 받은 원시 데이터
    /// - Throws: 네트워크 에러, API 키 에러, HTTP 상태 에러
    func fetch(from endpoint: Endpoint) async throws -> Data

    /// JSON 데이터를 특정 타입으로 디코딩하는 메서드
    /// - Parameters:
    ///   - data: 디코딩할 JSON 데이터
    ///   - type: 디코딩 타겟 타입
    /// - Returns: 디코딩된 객체, 실패 시 nil
    /// - Throws: 디코딩 에러
    func decode<T: Decodable>(data: Data, type: T.Type) throws -> T?
}
