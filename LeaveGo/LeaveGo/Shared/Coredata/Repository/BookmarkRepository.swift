//
//  BookmarkRepository.swift
//  LeaveGo
//
//  Created by 박동언 on 9/25/25.
//

import Foundation
import CoreData

final class BookmarkRepository: BookmarkRepositoryType {
    private let pc: PersistenceController

    init(pc: PersistenceController = .shared) {
        self.pc = pc
    }

    func createBookmark(_ dto: BookmarkDTO) async throws -> NSManagedObjectID {
        let bgContext = pc.newBackgroundContext(author: "bookmark.create")

        return try await bgContext.perform {
            let fetchRequest: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contentID == %@", dto.contentID)
            fetchRequest.fetchLimit = 1

            if let exist = try? bgContext.fetch(fetchRequest).first {
                return exist.objectID
            }

            let bookmark = Bookmark(context: bgContext)
            bookmark.title = dto.title ?? ""
            bookmark.contentID = dto.contentID
            bookmark.thumbnail = dto.thumbnail ?? ""
            bookmark.createAt = Date()

            do {
                try bgContext.save()
            } catch {
                throw BookmarkRepositoryError.saveFailed(error)
            }
            
            return bookmark.objectID
        }
    }

    func updateBookmark(_ id: NSManagedObjectID, _ dto: BookmarkDTO) async throws {
        let bgContext = pc.newBackgroundContext(author: "bookmark.update")

        try await bgContext.perform {
            guard let bookmark = try? bgContext.existingObject(with: id) as? Bookmark else {
                throw BookmarkRepositoryError.bookmarkNotFound
            }

            if let title = dto.title { bookmark.title = title }
            if let thumbnail = dto.thumbnail { bookmark.thumbnail = thumbnail }

            do {
                try bgContext.save()
            } catch {
                throw BookmarkRepositoryError.saveFailed(error)
            }
        }
    }

    func deleteBookmark(_ id: NSManagedObjectID) async throws {
        let bgContext = pc.newBackgroundContext(author: "bookmark.delete")

        try await bgContext.perform {
            guard let obj = try? bgContext.existingObject(with: id) else {
                throw BookmarkRepositoryError.bookmarkNotFound
            }
            
            bgContext.delete(obj)

            do {
                try bgContext.save()
            } catch {
                throw BookmarkRepositoryError.saveFailed(error)
            }
        }
    }

    func bookmarkID(for contentID: String) async throws -> NSManagedObjectID? {
        let bgContext = pc.newBackgroundContext(author: "bookmark.lookup")

        return try await bgContext.perform {
            let fetchRequest: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contentID == %@", contentID)
            fetchRequest.fetchLimit = 1

            return try bgContext.fetch(fetchRequest).first?.objectID
        }
    }
}
