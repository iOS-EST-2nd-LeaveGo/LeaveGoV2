//
//  View+asUIImage.swift
//  LeaveGo
//
//  Created by 이치훈 on 12/30/25.
//

import SwiftUI

extension View {
    func asMarkerImage(size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: self)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        controller.view.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
