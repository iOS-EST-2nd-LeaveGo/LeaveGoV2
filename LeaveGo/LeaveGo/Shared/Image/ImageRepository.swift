//
//  ImageRepository.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/21/25.
//

import SwiftUI

/// 이미지 캐싱과 로딩을 관리하는 Repository
/// 프로토콜 기반 ImageService를 주입받아 테스트/대체 구현이 가능하도록 설계
/// NSCache를 사용한 메모리 캐싱으로 성능 최적화 제공
@Observable
final class ImageRepository {
    /// 싱글톤 인스턴스
    static let shared = ImageRepository()
    /// 실제 이미지 다운로드를 담당하는 매니저
    let imageManager: ImageService
    
    /// URL을 키로 하는 이미지 메모리 캐시
    private let cache = NSCache<NSString, UIImage>()
    
    /// 의존성 주입을 지원하는 생성자 (테스트용)
    /// - Parameter imageManager: 이미지 다운로드를 담당하는 매니저, 기본값은 shared 인스턴스
    init(imageManager: ImageService = ImageManager.shared) {
        self.imageManager = imageManager
        
        // 캐시 설정: 최대 100개 이미지, 30MB 메모리 제한
        cache.countLimit = 100
        cache.totalCostLimit = 30 * 1024 * 1024
    }
    
    /// URL에서 이미지를 로드하며, 캐시를 우선적으로 확인
    /// - Parameter url: 로드할 이미지의 URL
    /// - Returns: 캐시된 이미지 또는 새로 다운로드한 이미지, 실패시 nil
    func loadImage(from url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        guard let image = await imageManager.fetchImage(from: url) else {
            return nil
        }
        
        cache.setObject(image, forKey: key)
        
        return image
    }
}
