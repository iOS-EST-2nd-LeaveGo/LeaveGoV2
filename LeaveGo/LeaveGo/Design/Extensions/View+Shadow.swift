//
//  View+Shadow.swift
//  LeaveGo
//
//  Created by 박동언 on 9/7/25.
//

import Foundation
import SwiftUI

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let light = ShadowStyle(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    static let medium = ShadowStyle(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let heavy = ShadowStyle(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
}

extension View {
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

    func defaultShadow() -> some View {
        self.shadow(.medium)
    }
}
