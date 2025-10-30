//
//  Endpoint.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/29/25.
//

import SwiftUI

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

extension Endpoint {
    var baseURL: URL {
        URL(string: "https://apis.data.go.kr/B551011/KorService2")!
    }
    
    var parameters: [String : Any]? {
        return [
            "MobileOS": "IOS",
            "MobileApp": "LeaveGo",
            "_type": "json",
        ]
    }

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
