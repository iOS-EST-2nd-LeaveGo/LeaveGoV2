//
//  LeaveGoApp.swift
//  LeaveGo
//
//  Created by 박동언 on 9/4/25.
//

import SwiftUI
import NMapsMap

@main
struct LeaveGoApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        NMFAuthManager.shared().ncpKeyId = APIKeys.naverMapClientId
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
