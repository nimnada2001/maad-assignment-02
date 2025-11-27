//
//  InventoryDashboardView.swift
//  Scan2Store
//
//  Screen 3: Inventory list with search, sort, edit, delete, and group functionality
//

import SwiftUI
import CoreData

enum SortOption: String, CaseIterable {
    case latest = "Latest"
    case name = "Name"
    case quantity = "Quantity"
}

struct InventoryDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \InventoryItem.dateAdded, ascending: false)],
        animation: .default
    ) private var allItems: FetchedResults<InventoryItem>
    
    @State private var searchText = ""
    @State private var sortOption: SortOption = .latest
    @State private var selectedItem: InventoryItem?
    @State private var isEditMode = false
    @State private var selectedItems = Set<UUID>()
    @State private var showingGroupDialog = false
    @State private var groupName = ""
    @State private var refreshID = UUID()
    
    private var filteredItems: [InventoryItem] {
        var items = Array(allItems)
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter { item in
                let customName = item.customName?.lowercased() ?? ""
                let label = item.label?.lowercased() ?? ""
                let notes = item.notes?.lowercased() ?? ""
                let group = item.groupName?.lowercased() ?? ""
                let search = searchText.lowercased()
                
                return customName.contains(search) || label.contains(search) || notes.contains(search) || group.contains(search)
            }
        }
        
        // Apply sort
        switch sortOption {
        case .latest:
            items.sort { ($0.dateAdded ?? Date.distantPast) > ($1.dateAdded ?? Date.distantPast) }
        case .name:
            items.sort { ($0.customName ?? "") < ($1.customName ?? "") }
        case .quantity:
            items.sort { $0.quantity > $1.quantity }
        }
        
        return items
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    listView
                }
            }
            .navigationTitle("Inventory")
            .searchable(text: $searchText, prompt: "Search items")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditMode {
                        Button("Done") {
                            isEditMode = false
                            selectedItems.removeAll()
                        }
                        .foregroundStyle(Color.appPrimary)
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isEditMode {
                        // Delete button
                        Button {
                            deleteSelectedItems()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .disabled(selectedItems.isEmpty)
                        
                        // Group button
                        Button {
                            showingGroupDialog = true
                        } label: {
                            Label("Group", systemImage: "rectangle.stack.badge.plus")
                        }
                        .disabled(selectedItems.isEmpty)
                    } else {
                        // Sort menu
                        Menu {
                            Picker("Sort", selection: $sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Label(option.rawValue, systemImage: sortIcon(for: option))
                                        .tag(option)
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }
                        
                        // Edit button
                        Button {
                            isEditMode = true
                        } label: {
                            Label("Select", systemImage: "checkmark.circle")
                        }
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                NavigationStack {
                    AddEditItemView(existingItem: item)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .onDisappear {
                    // Force refresh when sheet dismisses
                    viewContext.refreshAllObjects()
                    // Trigger view update
                    refreshID = UUID()
                }
            }
            .id(refreshID)
            .alert("Group Items", isPresented: $showingGroupDialog) {
                TextField("Group Name", text: $groupName)
                Button("Cancel", role: .cancel) {
                    groupName = ""
                }
                Button("Create Group") {
                    groupSelectedItems()
                }
            } message: {
                Text("Enter a name for the group. Selected items will be grouped together.")
            }
        }
    }
    
    // MARK: - List View
    private var listView: some View {
        List {
            // Group items by groupName if any
            let grouped = Dictionary(grouping: filteredItems) { $0.groupName ?? "Ungrouped" }
            let sortedGroups = grouped.keys.sorted { $0 == "Ungrouped" ? false : ($1 == "Ungrouped" ? true : $0 < $1) }
            
            ForEach(sortedGroups, id: \.self) { groupName in
                Section {
                    ForEach(grouped[groupName] ?? []) { item in
                        InventoryRowView(item: item, isSelected: item.id != nil && selectedItems.contains(item.id!), isEditMode: isEditMode)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isEditMode {
                                    toggleSelection(item)
                                } else {
                                    selectedItem = item
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if !isEditMode {
                                    Button(role: .destructive) {
                                        deleteItem(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                    
                                    Button {
                                        incrementQuantity(item)
                                    } label: {
                                        Label("Add One", systemImage: "plus.circle.fill")
                                    }
                                    .tint(.appPrimary)
                                    
                                    if item.groupName != nil {
                                        Button {
                                            ungroupItem(item)
                                        } label: {
                                            Label("Ungroup", systemImage: "rectangle.stack.badge.minus")
                                        }
                                        .tint(.orange)
                                    }
                                }
                            }
                    }
                } header: {
                    if groupName != "Ungrouped" {
                        HStack {
                            Image(systemName: "rectangle.stack.fill")
                                .font(.caption)
                            Text(groupName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            if isEditMode {
                                Button {
                                    ungroupAllInGroup(groupName)
                                } label: {
                                    Image(systemName: "rectangle.stack.badge.minus")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, isEditMode ? .constant(.active) : .constant(.inactive))
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Items Yet", systemImage: "square.stack.3d.up.slash")
                .symbolVariant(.fill)
        } description: {
            Text("Scan something to get started!")
                .font(.subheadline)
        } actions: {
            Button {
                // Navigate to scan tab would be handled by tab bar
            } label: {
                Label("Start Scanning", systemImage: "camera.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func sortIcon(for option: SortOption) -> String {
        switch option {
        case .latest: return "clock.fill"
        case .name: return "textformat.abc"
        case .quantity: return "number"
        }
    }
    
    // MARK: - Selection Management
    private func toggleSelection(_ item: InventoryItem) {
        guard let itemId = item.id else { return }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
            if selectedItems.contains(itemId) {
                selectedItems.remove(itemId)
            } else {
                selectedItems.insert(itemId)
            }
        }
    }
    
    // MARK: - Actions
    private func deleteItem(_ item: InventoryItem) {
        // Remove from selection if selected
        if let itemId = item.id {
            selectedItems.remove(itemId)
        }
        
        withAnimation(.easeOut) {
            viewContext.delete(item)
            
            do {
                try viewContext.save()
                // Process pending changes to ensure UI updates
                viewContext.processPendingChanges()
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } catch {
                print("Error deleting item: \(error)")
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteSelectedItems() {
        withAnimation(.easeOut) {
            let itemsToDelete = filteredItems.filter { item in
                guard let itemId = item.id else { return false }
                return selectedItems.contains(itemId)
            }
            
            for item in itemsToDelete {
                viewContext.delete(item)
            }
            
            selectedItems.removeAll()
            isEditMode = false
            
            do {
                try viewContext.save()
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } catch {
                print("Error deleting items: \(error)")
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func groupSelectedItems() {
        withAnimation {
            let itemsToGroup = filteredItems.filter { item in
                guard let itemId = item.id else { return false }
                return selectedItems.contains(itemId)
            }
            
            for item in itemsToGroup {
                item.groupName = groupName.isEmpty ? nil : groupName
            }
            
            selectedItems.removeAll()
            isEditMode = false
            groupName = ""
            
            do {
                try viewContext.save()
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } catch {
                print("Error grouping items: \(error)")
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func incrementQuantity(_ item: InventoryItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            item.quantity += 1
            
            do {
                try viewContext.save()
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            } catch {
                print("Error updating quantity: \(error)")
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func ungroupItem(_ item: InventoryItem) {
        withAnimation {
            item.groupName = nil
            
            do {
                try viewContext.save()
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } catch {
                print("Error ungrouping item: \(error)")
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func ungroupAllInGroup(_ groupName: String) {
        withAnimation {
            let itemsInGroup = filteredItems.filter { $0.groupName == groupName }
            
            for item in itemsInGroup {
                item.groupName = nil
            }
            
            do {
                try viewContext.save()
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } catch {
                print("Error ungrouping items: \(error)")
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Inventory Row View
struct InventoryRowView: View {
    let item: InventoryItem
    let isSelected: Bool
    let isEditMode: Bool
    
    init(item: InventoryItem, isSelected: Bool = false, isEditMode: Bool = false) {
        self.item = item
        self.isSelected = isSelected
        self.isEditMode = isEditMode
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Selection indicator in edit mode
            if isEditMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.appPrimary : .secondary)
                    .font(.title3)
                    .transition(.scale)
            }
            
            // Thumbnail with better styling
            Group {
                if let imageData = item.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        )
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Text content with proper typography
            VStack(alignment: .leading, spacing: 6) {
                Text(item.customName ?? "Unknown")
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 6) {
                    if let label = item.label, !label.isEmpty {
                        Label(label.capitalized, systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .labelStyle(.titleAndIcon)
                    }
                    
                    if let dateAdded = item.dateAdded {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text(dateAdded, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer(minLength: 8)
            
            // Quantity badge with system styling
            VStack(spacing: 2) {
                Text("\(item.quantity)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                
                Text("qty")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.appPrimary.opacity(0.1) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    InventoryDashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
