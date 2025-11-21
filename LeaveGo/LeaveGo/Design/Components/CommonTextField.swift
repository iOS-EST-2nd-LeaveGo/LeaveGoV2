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
    /// 필드의 포커스 상태를 담는 상태 변수
    @FocusState.Binding var isFocused: Bool
    
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
                .focused($isFocused)
        }
    }
}

#Preview {
    @FocusState var isFocused: Bool
    
    CommonTextField(label: "여행 이름", value: .constant("서울 여행"), prompt: "여행의 이름을 입력하세요", isFocused: $isFocused)
        .padding(.horizontal)
}
