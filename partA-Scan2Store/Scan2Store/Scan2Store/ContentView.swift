//
//  ContentView.swift
//  Scan2Store
//
//  Created by Nimnada Kirindage on 2025-11-27.
//
//  Note: This view is kept for compatibility but the app entry point is DetectView
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        DetectView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
