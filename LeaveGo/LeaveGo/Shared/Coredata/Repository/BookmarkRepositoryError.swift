//
//  BookmarkRepositoryError.swift
//  LeaveGo
//
//  Created by 박동언 on 9/25/25.
//

import Foundation

enum BookmarkRepositoryError: Error, LocalizedError {
    case bookmarkNotFound
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .bookmarkNotFound:
            return "Bookmark를 찾을 수 없습니다."
        case .saveFailed(let error):
            return "저장 실패: \(error.localizedDescription)"
        }
    }
}
