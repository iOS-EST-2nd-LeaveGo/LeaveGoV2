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
        case .invalidAPIKey: "🌐 NetworkManager: API 키가 유효하지 않음"
        case .invalidRequestURL: "🌐 NetworkManager: Request URL 구성 실패"
        case .invalidResponse: "🌐 NetworkManager: 유효하지 않은 Response"
        case let .clientError(statusCode): "🌐 NetworkManager: 클라이언트 에러 > \(statusCode)"
        case let .serverError(statusCode): "🌐 NetworkManager: 서버 에러 > \(statusCode)"
        case let .decodingFailed(decodingType): "🌐 NetworkManager: \(decodingType)으로 Decoding 실패"
        case let .unknownError(statusCode): "🌐 NetworkManager: 알 수 없는 에러 > \(statusCode)"
        }
    }
}
