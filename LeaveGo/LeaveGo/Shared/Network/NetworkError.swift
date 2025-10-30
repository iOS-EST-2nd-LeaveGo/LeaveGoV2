//
//  NetworkError.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/29/25.
//

import Foundation

enum NetworkError: Error {
    case invalidAPIKey
    case invalidResponse
    case decodingFailed(String)
    case clientError(Int)
    case serverError(Int)
    case unknownError(Int)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey: "🌐 NetworkManager: API 키가 유효하지 않음"
        case .invalidResponse: "🌐 NetworkManager: 유효하지 않은 Response"
        case let .decodingFailed(errorMessage): "🌐 NetworkManager: Decoding 실패 > \(errorMessage)"
        case let .clientError(statusCode): "🌐 NetworkManager: 클라이언트 에러 > \(statusCode)"
        case let .serverError(statusCode): "🌐 NetworkManager: 서버 에러 > \(statusCode)"
        case let .unknownError(statusCode): "🌐 NetworkManager: 알 수 없는 에러 > \(statusCode)"
        }
    }
}
