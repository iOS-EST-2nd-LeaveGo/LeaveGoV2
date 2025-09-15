//
//  PlaceHolderImageView.swift
//  LeaveGo
//
//  Created by Kitcat Seo on 9/16/25.
//

import SwiftUI

/// 사이즈를 조절할 수 있는 앱 로고를 이용한 Placeholder 이미지
struct PlaceholderImageView: View {
    var width: CGFloat = 50
    var cornerRadius: CGFloat = DesignToken.Radius.medium
    
    var body: some View {
        let height: CGFloat = {
            return width
        }()
        
        ZStack {
            Image("PlaceholderImage")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.8)
        }
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.lgBackgroundAccentLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(.lgBorderProminent)
        )
    }
}

#Preview {
    PlaceholderImageView(width: 150)
}
