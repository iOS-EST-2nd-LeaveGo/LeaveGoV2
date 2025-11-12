//
//  String+Extension.swift
//  LeaveGo
//
//  Created by 박동언 on 6/18/25.
//

import Foundation

// MARK: - HTML 문자열을 일반 텍스트로 변환하는 String 확장
extension String {
    /// HTML 형식의 문자열을 NSAttributedString을 이용해 일반 문자열로 변환합니다.
    /// <p> 등의 태그가 포함된 응답 값을 정제할 때 사용
    func htmlToPlainText() async -> String {
        return await Task.detached {
            guard let data = self.data(using: .utf8) else { return self }
            if let attributedString = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            ) {
                return attributedString.string
            }
            return self
        }.value
    }
    
    /// 콘텐츠 타입 ID 문자열을 ContentType enum으로 변환하는 함수
    /// 매칭되는 ContentType 또는 nil을 반환
    func toContentID() -> ContentType? {
        return [
            "12": .touristAttraction,
            "14": .cultureFacility,
            "28": .leisureSports,
            "38": .shopping,
            "39": .restaurant
        ][self] ?? nil
    }
}
