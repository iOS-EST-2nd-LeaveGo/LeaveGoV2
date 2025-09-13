//
//  PrimaryButton.swift
//  LeaveGo
//
//  Created by 박동언 on 9/7/25.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            if isEnabled {
                action()
            }
        } label: {
            Text(title)
                .font(.title3)
                .foregroundStyle(isEnabled ? .white : .gray.opacity(0.6))
        }
        .frame(height: DesignToken.Layout.buttonHeight)
        .frame(maxWidth: .infinity)
        .background {
            isEnabled ? .lgAccent : Color(.systemGray5)
        }
        .cornerRadius(DesignToken.Radius.medium)
        .disabled(!isEnabled)
    }
}
