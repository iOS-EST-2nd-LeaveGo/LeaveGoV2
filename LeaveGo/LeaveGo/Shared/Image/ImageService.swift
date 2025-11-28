//
//  ImageService.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/21/25.
//

import SwiftUI

/// 이미지 다운로드 서비스를 위한 프로토콜
/// 테스트 가능성과 의존성 주입을 위한 추상화 제공
protocol ImageService {
    /// URL에서 이미지를 비동기적으로 가져오는 메소드
    /// - Parameter url: 가져올 이미지의 URL
    /// - Returns: 다운로드된 UIImage 또는 실패시 nil
    func fetchImage(from url: URL) async -> UIImage?
}
