//
//  ImageRepository.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/21/25.
//

import SwiftUI

@Observable
final class ImageRepository {
    static let shared = ImageRepository()
    let imageManager: ImageManager = .shared
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 30 * 1024 * 1024
    }
    
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
