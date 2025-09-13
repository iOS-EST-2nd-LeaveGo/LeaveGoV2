//
//  View+Stroke.swift
//  LeaveGo
//
//  Created by 박동언 on 9/8/25.
//

import Foundation
import SwiftUI

struct StrokeStyle {
    let color: Color
    let lineWidth: CGFloat

    static let regular = StrokeStyle(color: .lgBorder, lineWidth: 1)
    static let prominent = StrokeStyle(color: .lgBorderProminent, lineWidth: 2)
}

extension View {
    func stroke(_ style: StrokeStyle, cornerRadius: CGFloat = DesignToken.Radius.medium) -> some View {
        self.overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(style.color, lineWidth: style.lineWidth)
            }
    }
}
