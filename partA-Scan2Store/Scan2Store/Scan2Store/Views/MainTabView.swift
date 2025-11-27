//
//  MainTabView.swift
//  Scan2Store
//
//  Main tab bar navigation structure with SF icons
//

import SwiftUI
import CoreData

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Scan Tab
            DetectView()
                .tabItem {
                    Label("Scan", systemImage: "camera.fill")
                }
                .tag(0)
            
            // Inventory Tab
            InventoryDashboardView()
                .tabItem {
                    Label("Inventory", systemImage: "square.stack.3d.up.fill")
                }
                .tag(1)
        }
        .tint(.appPrimary)
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

