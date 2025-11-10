//
//  NetworkManager.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/28/25.
//

import Foundation

/// NetworkService 프로토콜을 구현한 구체적인 네트워크 매니저 클래스
final class NetworkManager: NetworkService {
    /// 싱글톤 인스턴스
    static let shared = NetworkManager()

    /// URLSession 인스턴스
    private let session: URLSession

    /// NetworkManager 초기화 (private - 싱글톤 패턴)
    /// - Parameter session: URLSession 인스턴스 (기본값: .shared)
    private init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch(from endpoint: Endpoint) async throws -> Data {
        guard let apiKey = APIKeys.tourAPI else {
            print(NetworkError.invalidAPIKey.localizedDescription)
            throw NetworkError.invalidAPIKey
        }
        
        var request = try endpoint.urlRequest()

        guard let requestURL = request.url,
              var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) else {
            print(NetworkError.invalidRequestURL.localizedDescription)
            throw NetworkError.invalidRequestURL
        }

        var queryItems = urlComponents.queryItems ?? []

        // API 키를 디코딩해서 원본 형태로 만든 후 추가
        let decodedApiKey = apiKey.removingPercentEncoding ?? apiKey
        queryItems.append(URLQueryItem(name: "serviceKey", value: decodedApiKey))

        urlComponents.queryItems = queryItems

        guard let finalURL = urlComponents.url else {
            print(NetworkError.invalidRequestURL.localizedDescription)
            throw NetworkError.invalidRequestURL
        }
        request.url = finalURL
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print(NetworkError.invalidResponse.localizedDescription)
            throw NetworkError.invalidResponse
        }
        
        try validateResponse(httpResponse)
        
        return data
    }
    
    func decode<T: Decodable>(data: Data, type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            print(NetworkError.decodingFailed("\(type)").localizedDescription)
            throw NetworkError.decodingFailed("\(type)")
        }
    }
    
    /// HTTP 응답의 상태 코드를 검증하는 private 메서드
    /// - Parameter response: 검증할 HTTP 응답
    /// - Throws: 상태 코드에 따른 적절한 NetworkError
    private func validateResponse(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 400...499:
            print(NetworkError.clientError(response.statusCode))
            throw NetworkError.clientError(response.statusCode)
        case 500...599:
            print(NetworkError.serverError(response.statusCode))
            throw NetworkError.serverError(response.statusCode)
        default:
            print(NetworkError.unknownError(response.statusCode))
            throw NetworkError.unknownError(response.statusCode)
        }
    }
}
