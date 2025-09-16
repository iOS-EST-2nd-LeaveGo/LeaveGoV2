//
//  DesignToken.swift
//  LeaveGo
//
//  Created by 박동언 on 9/7/25.
//

import Foundation
import SwiftUI

enum DesignToken {
    enum Spacing {
        /// 32
        static let xxxLarge: CGFloat = 32
        /// 24
        static let xxLarge: CGFloat = 24
        /// 기본적인 spacing, 16
        static let large: CGFloat = 16
        /// 8
        static let medium: CGFloat = 8
        /// 4
        static let small: CGFloat = 4
    }

    enum Layout {
        /// PrimaryButton의 높이, 48
        static let buttonHeight: CGFloat = 48
        /// BottomActionButton의 높이 + 그래디언트 + 하단 패딩
        static let bottomActionButtonHeight: CGFloat = buttonHeight + DesignToken.Spacing.xxLarge + DesignToken.Spacing.large
    }

    enum Radius {
        /// 24
        static let large: CGFloat = 24
        /// 기본적인 radius, 16
        static let medium: CGFloat = 16
        /// 8
        static let small: CGFloat = 8
    }

    enum AppAnimation {

    }
}
