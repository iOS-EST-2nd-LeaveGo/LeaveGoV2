//
//  ImageManager.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/21/25.
//

import SwiftUI

/// 이미지 다운로드를 담당하는 서비스
/// ImageService 프로토콜을 구현하여 네트워크에서 이미지를 가져오는 기능 제공
struct ImageManager: ImageService {
    static let shared = ImageManager()
    
    private init() { }
    
    /// URL에서 이미지를 비동기적으로 다운로드
    /// - Parameter url: 다운로드할 이미지의 URL
    /// - Returns: 다운로드된 UIImage 또는 실패시 nil
    func fetchImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            return image
        } catch {
            print(error)
            return nil
        }
    }
}
