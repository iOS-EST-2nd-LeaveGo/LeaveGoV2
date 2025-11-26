//
//  ImageService.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 11/21/25.
//

import SwiftUI

protocol ImageService {
    func fetchImage(from url: URL) async -> UIImage?
}
