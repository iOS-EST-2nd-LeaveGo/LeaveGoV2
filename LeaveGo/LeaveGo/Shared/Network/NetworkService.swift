//
//  NetworkService.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 10/29/25.
//

import SwiftUI

protocol NetworkService {
    func fetch(from endpoint: Endpoint) async throws -> Data
    func decode<T: Decodable>(data: Data, type: T.Type) throws -> T?
}
