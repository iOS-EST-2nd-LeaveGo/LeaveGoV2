//
//  ImageManager.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/21/25.
//

import SwiftUI

struct ImageManager: ImageService {
    static let shared = ImageManager()
    
    private init() { }
    
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
