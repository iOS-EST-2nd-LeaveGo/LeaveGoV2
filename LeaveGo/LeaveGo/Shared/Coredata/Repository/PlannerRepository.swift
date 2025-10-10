//
//  PlannerRepository.swift
//  LeaveGo
//
//  Created by 박동언 on 9/21/25.
//

import Foundation
import CoreData

final class PlannerRepository: PlannerRepositoryType {
    private let pc: PersistenceController

    init(pc: PersistenceController = .shared) {
        self.pc = pc
    }

    // MARK: Planner와 Place 생성 or 업데이트
    func upsertPlanner(_ dto: PlannerDTO, places: [PlannerPlaceDTO]) async throws -> NSManagedObjectID {
        let bgContext = pc.newBackgroundContext(author: "planner.upsert")

        return try await bgContext.perform {
            let planner: Planner

            // Planner가 이미 있으면 가져오고, 없으면 새로 생성
            let fetch: NSFetchRequest<Planner> = Planner.fetchRequest()
            fetch.fetchLimit = 1
            fetch.predicate = NSPredicate(format: "id == %@", dto.id as CVarArg)

            if let found = try bgContext.fetch(fetch).first {
                planner = found
            } else {
                planner = Planner(context: bgContext)
                planner.id = dto.id
                planner.createAt = Date()
            }

            planner.title = dto.title
            planner.startDate = dto.startDate
            planner.endDate = dto.endDate
            planner.thumbnail = dto.thumbnail ?? ""

            // 기존 Place 목록 fetch
            let placeFetch: NSFetchRequest<PlannerPlace> = PlannerPlace.fetchRequest()
            placeFetch.predicate = NSPredicate(format: "planner == %@", planner)
            let existingPlaces = try bgContext.fetch(placeFetch)

            var existingByID: [UUID: PlannerPlace] = [:]
            existingPlaces.forEach { if let pid = $0.id { existingByID[pid] = $0 } }

            // 전달받은 목록을 기준으로 Insert/Update
            var keepIDs = Set<UUID>()

            for dto in places {
                if let existing = existingByID[dto.id] {
                    // Update
                    existing.title = dto.title
                    existing.contentID = dto.contentID
                    existing.thumbnail = dto.thumbnail ?? ""
                    existing.date = dto.date
                    existing.order = dto.order
                    keepIDs.insert(dto.id)
                } else {
                    // Insert
                    let new = PlannerPlace(context: bgContext)
                    new.id = dto.id
                    new.title = dto.title
                    new.contentID = dto.contentID
                    new.thumbnail = dto.thumbnail ?? ""
                    new.date = dto.date
                    new.order = dto.order
                    new.createAt = Date()
                    new.planner = planner
                    keepIDs.insert(dto.id)
                }
            }

            // 전달받은 목록에 포함되지 않은 기존 장소 삭제
            for obj in existingPlaces {
                guard let id = obj.id else {
                    bgContext.delete(obj)
                    continue
                }
                if !keepIDs.contains(id) {
                    bgContext.delete(obj)
                }
            }

            // 저장
            do {
                try bgContext.save()
            } catch {
                throw PlannerRepositoryError.saveFailed(error)
            }

            return planner.objectID
        }
    }

    // MARK: Planner Create/Update/Delete
    func createPlanner(_ dto: PlannerDTO) async throws -> NSManagedObjectID {
        let bgContext = pc.newBackgroundContext(author: "planner.create")

        return try await bgContext.perform {
            let planner = Planner(context: bgContext)

            planner.id = UUID()
            planner.title = dto.title
            planner.createAt = Date()
            planner.startDate = dto.startDate
            planner.endDate = dto.endDate
            planner.thumbnail = dto.thumbnail ?? ""

            do {
                try bgContext.save()
            } catch {
                throw PlannerRepositoryError.saveFailed(error)
            }

            return planner.objectID
        }
    }

    func updatePlanner(_ id: NSManagedObjectID, _ dto: PlannerDTO) async throws {
        let bgContext = pc.newBackgroundContext(author: "planner.update")

        try await bgContext.perform {
            guard let planner = try? bgContext.existingObject(with: id) as? Planner else {
                throw PlannerRepositoryError.plannerNotFound
            }

            planner.title = dto.title
            planner.startDate = dto.startDate
            planner.endDate = dto.endDate

            if let thumbnail = dto.thumbnail { planner.thumbnail = thumbnail }

            do {
                try bgContext.save()
            } catch {
                throw PlannerRepositoryError.saveFailed(error)
            }
        }
    }

    func deletePlanner(_ id: NSManagedObjectID) async throws {
        let bgContext = pc.newBackgroundContext(author: "planner.delete")

        try await bgContext.perform {
            guard let obj = try? bgContext.existingObject(with: id) else {
                throw PlannerRepositoryError.plannerNotFound
            }

            bgContext.delete(obj)

            do {
                try bgContext.save()
            } catch {
                throw PlannerRepositoryError.saveFailed(error)
            }
        }
    }

    // MARK: Place ADD/Update/Delete
    func addPlace(to plannerID: NSManagedObjectID, _ dto: PlannerPlaceDTO) async throws -> NSManagedObjectID {
        let bgContext = pc.newBackgroundContext(author: "place.add")

        return try await bgContext.perform {
            guard let planner = try? bgContext.existingObject(with: plannerID) as? Planner else {
                throw PlannerRepositoryError.plannerNotFound
            }

            let place = PlannerPlace(context: bgContext)

            place.id = UUID()
            place.title = dto.title
            place.contentID = dto.contentID
            place.thumbnail = dto.thumbnail ?? ""
            place.date = dto.date
            place.createAt = Date()
            place.order = dto.order
            place.planner = planner

            do {
                try bgContext.save()
            } catch {
                throw PlannerRepositoryError.saveFailed(error)
            }

            return place.objectID
        }
    }

    func addPlaces(to plannerID: NSManagedObjectID, _ dtos: [PlannerPlaceDTO]) async throws {
        let bgContext = pc.newBackgroundContext(author: "places.add")

        try await bgContext.perform {
            guard let planner = try? bgContext.existingObject(with: plannerID) as? Planner else {
                throw PlannerRepositoryError.plannerNotFound
            }

            for dto in dtos {
                let place = PlannerPlace(context: bgContext)

                place.id = UUID()
                place.title = dto.title
                place.contentID = dto.contentID
                place.thumbnail = dto.thumbnail ?? ""
                place.date = dto.date
                place.createAt = Date()
                place.order = dto.order
                place.planner = planner
            }

            do {
                try bgContext.save()
            } catch {
                throw PlannerRepositoryError.saveFailed(error)
            }
        }
    }

    func updatePlace(_ placeID: NSManagedObjectID, _ dto: PlannerPlaceDTO) async throws {
        let bgContext = pc.newBackgroundContext(author: "place.update")

        try await bgContext.perform {
            guard let place = try? bgContext.existingObject(with: placeID) as? PlannerPlace else {
                throw PlannerRepositoryError.placeNotFound
            }

            place.title = dto.title
            place.contentID = dto.contentID
            place.date = dto.date
            place.order = dto.order

            if let thumbnail = dto.thumbnail { place.thumbnail = thumbnail }

            do {
                try bgContext.save()
            } catch {
                throw PlannerRepositoryError.saveFailed(error)
            }
        }
    }

    func deletePlace(_ placeID: NSManagedObjectID) async throws {
        let bgContext = pc.newBackgroundContext(author: "place.delete")

        try await bgContext.perform {
            guard let obj = try? bgContext.existingObject(with: placeID) else {
                throw PlannerRepositoryError.placeNotFound
            }

            bgContext.delete(obj)
            
            do {
                try bgContext.save()
            } catch {
                throw PlannerRepositoryError.saveFailed(error)
            }
        }
    }
}
