//
//  Persistence.swift
//  Scan2Store
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import CoreData
import Combine

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample inventory items for preview
        for i in 0..<5 {
            let newItem = InventoryItem(context: viewContext)
            newItem.id = UUID()
            newItem.label = ["bottle", "cup", "laptop", "phone", "book"][i]
            newItem.customName = ["Water Bottle", "Coffee Cup", "MacBook", "iPhone", "Swift Book"][i]
            newItem.quantity = Int16(i + 1)
            newItem.confidence = 0.75 + Double(i) * 0.05
            newItem.dateAdded = Date()
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Scan2Store")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.undoManager = nil
        // Enable automatic refreshing
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }
}
