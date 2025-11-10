//
//  Endpoint.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/29/25.
//

import Foundation

/// API 서비스 타입 정의
enum APIType {
    /// 한국관광공사 Tour API
    case tour
}

/// HTTP API 엔드포인트를 정의하는 프로토콜
protocol Endpoint {
    /// 사용할 API 서비스 타입
    var apiType: APIType { get set }

    /// API 기본 URL
    var baseURL: URL { get }

    /// API 엔드포인트 경로
    var path: String { get }

    /// HTTP 메서드 (GET, POST 등)
    var method: HTTPMethod { get }

    /// HTTP 헤더 정보
    var headers: [String: String]? { get }

    /// 요청 파라미터 (쿼리 스트링 또는 요청 바디)
    /// - Note: 실제 파라미터는 각 엔드포인트의 init()에서 defaultParameters와 함께 설정됨
    var parameters: [String: Any]? { get set }
}

extension Endpoint {
    /// API 타입에 따른 기본 URL 반환
    var baseURL: URL {
        switch apiType {
        case .tour: return URL(string: "https://apis.data.go.kr/B551011/KorService2")!
        }
    }

    /// 기본 HTTP 헤더 (기본값: nil)
    var headers: [String: String]? {
        return nil
    }

    /// API 타입별 기본 파라미터
    var defaultParameters: [String: Any] {
        switch apiType {
        case .tour: return [
            "MobileOS": "IOS",
            "MobileApp": "LeaveGo",
            "_type": "json",
        ]
        }
    }

    /// URLRequest 생성 메서드
    /// - Returns: 설정된 엔드포인트 정보를 기반으로 생성된 URLRequest
    /// - Throws: URL 생성 또는 파라미터 직렬화 실패 시 에러
    func urlRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        if let parameters = parameters {
            if method == .get {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = components?.url
            } else {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            }
        }
        return request
    }
}
