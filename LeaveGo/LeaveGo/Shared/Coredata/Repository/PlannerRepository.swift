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
            
            planner.startDate = dto.startDate
            planner.endDate = dto.endDate

            if let title = dto.title { planner.title = title}
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

            place.contentID = dto.contentID
            place.date = dto.date
            place.order = dto.order

            if let title = dto.title { place.title = title }
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
