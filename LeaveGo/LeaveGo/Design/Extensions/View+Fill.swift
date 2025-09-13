//
//  View+Fill.swift
//  LeaveGo
//
//  Created by 박동언 on 9/8/25.
//

import Foundation
import SwiftUI

struct FillStyle {
    let color: Color

    static let white = FillStyle(color: .lgTextField)
    static let accent = FillStyle(color: .lgBackgroundAccent)
    static let lightAccent = FillStyle(color: .lgBackgroundAccentLight)

}

extension View {
    func fill(_ style: FillStyle, cornerRadius: CGFloat = DesignToken.Radius.medium) -> some View {
        self.background {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(style.color)
        }
    }
}
