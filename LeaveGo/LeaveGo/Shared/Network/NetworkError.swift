//
//  NetworkError.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/29/25.
//

import Foundation

enum NetworkError: Error {
    case invalidAPIKey
    case invalidRequestURL
    case invalidResponse
    case clientError(Int)
    case serverError(Int)
    case decodingFailed(String)
    case unknownError(Int)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey: return "🌐 NetworkManager: API 키가 유효하지 않음"
        case .invalidRequestURL: return "🌐 NetworkManager: Request URL 구성 실패"
        case .invalidResponse: return "🌐 NetworkManager: 유효하지 않은 Response"
        case let .clientError(statusCode): return "🌐 NetworkManager: 클라이언트 에러 > \(statusCode)"
        case let .serverError(statusCode): return "🌐 NetworkManager: 서버 에러 > \(statusCode)"
        case let .decodingFailed(decodingType): return "🌐 NetworkManager: \(decodingType)으로 Decoding 실패"
        case let .unknownError(statusCode): return "🌐 NetworkManager: 알 수 없는 에러 > \(statusCode)"
        }
    }
}
