//
//  BottomActionButton.swift
//  LeaveGo
//
//  Created by 박동언 on 9/7/25.
//

import SwiftUI

struct BottomActionButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [
                    .lgBackground.opacity(0),
                    .lgBackground.opacity(1),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: DesignToken.Spacing.xxLarge)
            .allowsHitTesting(false)

            PrimaryButton(title: title, isEnabled: isEnabled, action: action)
                .padding(.horizontal, DesignToken.Spacing.large)
                .padding(.bottom, DesignToken.Spacing.large)
                .background(.lgBackground)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    BottomActionButton(title: "Next", isEnabled: false, action: {})
}
