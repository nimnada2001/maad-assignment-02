//
//  AddEditItemView.swift
//  Scan2Store
//
//  Screen 2: Confirm and save detected item to Core Data
//

import SwiftUI
import CoreData

struct AddEditItemView: View {
    let detection: DetectionResult?
    let image: UIImage?
    
    // For editing existing items
    let existingItem: InventoryItem?
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var customName: String = ""
    @State private var quantity: Int = 1
    @State private var notes: String = ""
    @State private var itemImage: UIImage?
    
    @FocusState private var isNameFocused: Bool
    
    init(detection: DetectionResult? = nil, image: UIImage? = nil, existingItem: InventoryItem? = nil) {
        self.detection = detection
        self.image = image
        self.existingItem = existingItem
        
        if let item = existingItem {
            _customName = State(initialValue: item.customName ?? "")
            _quantity = State(initialValue: Int(item.quantity))
            _notes = State(initialValue: item.notes ?? "")
            if let imageData = item.imageData, let img = UIImage(data: imageData) {
                _itemImage = State(initialValue: img)
            }
        } else if let detection = detection {
            _customName = State(initialValue: detection.label.capitalized)
            _itemImage = State(initialValue: detection.croppedUIImage)
        }
    }
    
    var body: some View {
        Form {
            Section {
                // Thumbnail with better styling
                HStack {
                    Spacer()
                    if let img = itemImage ?? detection?.croppedUIImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(width: 140, height: 140)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                            )
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
            }
            .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
            .listRowBackground(Color.clear)
            
            // Detection info section
            if let detection = detection {
                Section {
                    HStack {
                        Label("Detected Label", systemImage: "tag")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(detection.label.capitalized)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                    
                    HStack {
                        Label("Confidence", systemImage: "gauge")
                            .foregroundStyle(.secondary)
                        Spacer()
                        HStack(spacing: 6) {
                            Text(detection.confidencePercentage)
                                .fontWeight(.medium)
                                .monospacedDigit()
                                .foregroundStyle(confidenceColor(detection.confidence))
                            
                            Image(systemName: confidenceIcon(detection.confidence))
                                .font(.caption)
                                .foregroundStyle(confidenceColor(detection.confidence))
                        }
                    }
                } header: {
                    Text("Detection Info")
                }
            }
            
            // Item details section
            Section {
                TextField("Custom Name", text: $customName, prompt: Text("Enter item name"))
                    .focused($isNameFocused)
                    .textInputAutocapitalization(.words)
                
                Stepper(value: $quantity, in: 1...100) {
                    HStack {
                        Label("Quantity", systemImage: "number")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(quantity)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                
                TextField("Notes (optional)", text: $notes, prompt: Text("Add notes..."), axis: .vertical)
                    .lineLimit(3...6)
                    .textInputAutocapitalization(.sentences)
            } header: {
                Text("Item Details")
            } footer: {
                if customName.isEmpty {
                    Text("Item name is required")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(existingItem != nil ? "Edit Item" : "Add Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveItem()
                }
                .fontWeight(.semibold)
                .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            // Auto-focus name field for new items
            if existingItem == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFocused = true
                }
            }
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.7 {
            return AppTheme.successColor
        } else if confidence >= 0.5 {
            return AppTheme.warningColor
        } else {
            return AppTheme.errorColor
        }
    }
    
    private func confidenceIcon(_ confidence: Double) -> String {
        if confidence >= 0.7 {
            return "checkmark.circle.fill"
        } else if confidence >= 0.5 {
            return "exclamationmark.triangle.fill"
        } else {
            return "xmark.circle.fill"
        }
    }
    
    private func saveItem() {
        withAnimation {
            let item: InventoryItem
            
            if let existing = existingItem {
                // Update existing item
                item = existing
            } else {
                // Create new item
                item = InventoryItem(context: viewContext)
                item.id = UUID()
                item.dateAdded = Date()
                
                if let detection = detection {
                    item.label = detection.label
                    item.confidence = detection.confidence
                }
            }
            
            // Update fields
            item.customName = customName.trimmingCharacters(in: .whitespaces)
            item.quantity = Int16(quantity)
            item.notes = notes.isEmpty ? nil : notes
            
            // Save image
            if let imageToSave = itemImage ?? detection?.croppedUIImage {
                item.imageData = imageToSave.jpegData(compressionQuality: 0.8)
            }
            
            // Save context
            do {
                // Save changes
                try viewContext.save()
                
                // Explicitly refresh the object to ensure changes are visible
                viewContext.refresh(item, mergeChanges: true)
                
                // Process pending changes to ensure UI updates immediately
                viewContext.processPendingChanges()
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                dismiss()
            } catch {
                print("Error saving item: \(error)")
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let detection = DetectionResult(
        label: "bottle",
        confidence: 0.85,
        boundingBox: CGRect(x: 0.3, y: 0.3, width: 0.2, height: 0.3),
        croppedUIImage: nil
    )
    
    return NavigationStack {
        AddEditItemView(detection: detection)
    }
    .environment(\.managedObjectContext, context)
}
