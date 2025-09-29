//
//  BookmarkRepositoryType.swift
//  LeaveGo
//
//  Created by 박동언 on 9/25/25.
//

import CoreData

protocol BookmarkRepositoryType {
    func createBookmark(_ dto: BookmarkDTO) async throws -> NSManagedObjectID
    func updateBookmark(_ id: NSManagedObjectID, _ dto: BookmarkDTO) async throws
    func deleteBookmark(_ id: NSManagedObjectID) async throws
    func bookmarkID(for contentID: String) async throws -> NSManagedObjectID?
}
