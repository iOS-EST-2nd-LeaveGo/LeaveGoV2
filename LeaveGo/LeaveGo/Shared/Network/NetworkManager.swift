//
//  NetworkManager.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/28/25.
//

import Foundation

final class NetworkManager: NetworkService {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch(from endpoint: Endpoint) async throws -> Data {
        guard let apiKey = APIKeys.tourAPI else {
            print(NetworkError.invalidAPIKey.localizedDescription)
            throw NetworkError.invalidAPIKey
        }
        
        var request = try endpoint.urlRequest()
        
        if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
            var queryItems = urlComponents.queryItems ?? []

            // API 키를 디코딩해서 원본 형태로 만든 후 추가
            let decodedApiKey = apiKey.removingPercentEncoding ?? apiKey
            queryItems.append(URLQueryItem(name: "serviceKey", value: decodedApiKey))

            urlComponents.queryItems = queryItems
            request.url = urlComponents.url
        }
        
        print("🌐 NetworkManager: \(request.url?.absoluteString ?? "")")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print(NetworkError.invalidResponse.localizedDescription)
            throw NetworkError.invalidResponse
        }
        
        try validateResponse(httpResponse)
        
        return data
    }
    
    func decode<T: Decodable>(data: Data, type: T.Type) throws -> T? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            print(NetworkError.decodingFailed("\(type)").localizedDescription)
            throw NetworkError.decodingFailed("\(type)")
        }
    }
    
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
