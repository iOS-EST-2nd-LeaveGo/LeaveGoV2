//
//  CommonTextField.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/16/25.
//

import SwiftUI

/// 라벨 텍스트를 지정할 수 있는 텍스트필드입니다.
struct CommonTextField: View {
    /// (옵셔널) 텍스트 필드 위에 표시할 라벨
    var label: String? = nil
    /// 텍스트 필드의 입력값과 바인딩되는 문자열
    @Binding var value: String
    /// 필드가 비어있을 때 보여줄 플레이스홀더 텍스트
    let prompt: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignToken.Spacing.medium) {
            if let label {
                Text(label)
                    .padding(.leading, DesignToken.Spacing.small)
                    .font(.footnote)
                    .foregroundStyle(.lgLabelSecondary)
            }
            
            TextField(prompt, text: $value)
                .frame(height: DesignToken.Layout.buttonHeight)
                .padding(.horizontal, DesignToken.Spacing.large)
                .background(
                    RoundedRectangle(cornerRadius: DesignToken.Radius.medium)
                        .fill(.lgTextField)
                )
        }
    }
}

#Preview {
    CommonTextField(label: "dd", value: .constant("dd"), prompt: "여행의 이름을 입력하세요")
}
