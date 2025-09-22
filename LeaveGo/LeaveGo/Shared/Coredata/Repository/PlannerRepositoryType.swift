//
//  PlannerRepositoryType.swift
//  LeaveGo
//
//  Created by 박동언 on 9/21/25.
//

import Foundation
import CoreData

// 읽기는 View에서 @FetchRequest로
// 모든 쓰기는 이 프로토콜 통해서
protocol PlannerRepositoryType {
    // Planner
    func createPlanner(_ dto: PlannerDTO) async throws -> NSManagedObjectID
    func updatePlanner(_ id: NSManagedObjectID, _ dto: PlannerDTO) async throws
    func deletePlanner(_ id: NSManagedObjectID) async throws

    // Place
    func addPlace(to plannerID: NSManagedObjectID, _ dto: PlannerPlaceDTO) async throws -> NSManagedObjectID
    func updatePlace(_ placeID: NSManagedObjectID, _ dto: PlannerPlaceDTO) async throws
    func deletePlace(_ placeID: NSManagedObjectID) async throws
}
