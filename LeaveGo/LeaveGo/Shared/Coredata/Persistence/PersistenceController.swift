//
//  Persistence.swift
//  LeaveGo
//
//  Created by 박동언 on 9/4/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // 프리뷰/테스트에 쓰는 임시 저장소
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // 샘플데이터 삽입
        let calendar = Calendar.current
        let today = Date()

        for p in 0..<3 {
            let calendar = Calendar.current

            let planner = Planner(context: viewContext)

            planner.id = UUID()
            planner.title = "샘플 플래너 \(p + 1)"
            planner.createAt = today
            planner.startDate = today
            planner.endDate = calendar.date(byAdding: .day, value: 7, to: today) ?? today

            for i in 0..<3 {
                let place = PlannerPlace(context: viewContext)
                place.id = UUID()
                place.title = "장소 \(i + 1) - P\(p + 1)"
                place.contentID = "content-\(p+1)-\(i+1)"
                place.createAt = today
                place.date = calendar.date(byAdding: .day, value: i, to: today) ?? today
                place.order = Int16(i)

                place.planner = planner
            }
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LeaveGo")

        guard let desc = container.persistentStoreDescriptions.first else {
            fatalError("Missing persistent store description")
        }

        if inMemory {
            desc.url = URL(fileURLWithPath: "/dev/null")
        }

        // 라이트웨이트 마이그레이션 옵션
        desc.shouldMigrateStoreAutomatically = true
        desc.shouldInferMappingModelAutomatically = true

        // Persistent History Tracking 변경 로그를 남겨서 다른 컨텍스트/프로세스가 안전하게 병합할 수 있도록 해줌
        // Remote Change : 다른 프로세스(위젯 등)에서 Core Data를 수정해도 앱이 알림을 받아 UI를 갱신
        desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // 배포용: 사용자 친화 처리 필요
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        // 메인 컨텍스트 설정
        let viewContext = container.viewContext
        viewContext.name = "viewContext"

        // Parent 병합 자동 반영
        viewContext.automaticallyMergesChangesFromParent = true

        // 병합 정책 명시 (UI에서 수정한 값 우선)
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // 변경 작성자 지정 (히스토리 트래킹)
        viewContext.transactionAuthor = "app"
    }

    func newBackgroundContext(author: String = "bg") -> NSManagedObjectContext {
        let bgContext = container.newBackgroundContext()
        bgContext.name = "backgroundContext-\(author)"

        // Parent 병합 자동 반영
        bgContext.automaticallyMergesChangesFromParent = true

        // 병합 정책 (스토어 값 우선 → 충돌 최소화)
        bgContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        // 변경 작성자 지정 (히스토리 트래킹)
        bgContext.transactionAuthor = author

        return bgContext
    }

    // 저장 헬퍼
    @discardableResult
    func save(_ context: NSManagedObjectContext) throws -> Bool {
        guard context.hasChanges else { return false }
        try context.save()
        return true
    }
}
