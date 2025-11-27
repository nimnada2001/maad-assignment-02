//
//  Scan2StoreApp.swift
//  Scan2Store
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI
import CoreData

@main
struct Scan2StoreApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
