//
//  PlannerRepositioryError.swift
//  LeaveGo
//
//  Created by 박동언 on 9/21/25.
//

import Foundation

enum PlannerRepositoryError: Error, LocalizedError {
    case plannerNotFound
    case placeNotFound
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .plannerNotFound:
            return "Planner 객체를 찾을 수 없습니다."
        case .placeNotFound:
            return "Place 객체를 찾을 수 없습니다."
        case .saveFailed(let error):
            return "저장 실패: \(error.localizedDescription)"
        }
    }
}
