//
//  DetectView.swift
//  Scan2Store
//
//  Screen 1: Camera capture + photo import with YOLO detection
//

import SwiftUI
import PhotosUI
import AVFoundation
import CoreData

struct DetectView: View {
    @StateObject private var detector = YOLODetector()
    @State private var detectionMode: DetectionMode = .camera
    @State private var detections: [DetectionResult] = []
    @State private var selectedImage: UIImage?
    // No threshold - show all detections
    private let confidenceThreshold: Double = 0.0
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isProcessing = false
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDetection: DetectionResult?
    
    enum DetectionMode: String, CaseIterable {
        case camera = "Capture Photo"
        case photo = "Import Photo"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode selector with proper spacing
                Picker("Detection Mode", selection: $detectionMode) {
                    ForEach(DetectionMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .onChange(of: detectionMode) { oldValue, newValue in
                    handleModeChange(from: oldValue, to: newValue)
                }
                
                // Preview area with detections overlay - enhanced with corner radius
                ZStack {
                    previewView
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    
                    // Detection overlay
                    detectionOverlay
                    
                    // Processing indicator
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                
                // Hint text with better styling
                if !detections.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                        Text("Tap a detection box to add item")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.vertical, 8)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Control bar
                controlBar
            }
            .navigationTitle("Scan Items")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedDetection) { detection in
                NavigationStack {
                    AddEditItemView(detection: detection, image: selectedImage)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingCamera) {
                CameraCaptureView(capturedImage: $capturedImage)
            }
            .onChange(of: capturedImage) { _, newImage in
                if let image = newImage {
                    selectedImage = image
                    runDetection(on: image)
                    detectionMode = .photo
                }
            }
        }
    }
    
    // MARK: - Preview View
    @ViewBuilder
    private var previewView: some View {
        if let image = selectedImage {
            // Show captured/imported image
            GeometryReader { geometry in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .contentShape(Rectangle())
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            // Empty state - prompt user to capture or import
            VStack(spacing: 20) {
                Image(systemName: detectionMode == .camera ? "camera.fill" : "photo.on.rectangle")
                    .font(.system(size: 56))
                    .foregroundStyle(.secondary)
                    .symbolVariant(.fill)
                
                VStack(spacing: 8) {
                    Text(detectionMode == .camera ? "No Photo Captured" : "No Image Selected")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(detectionMode == .camera ? "Tap the camera button to capture a photo" : "Import a photo to detect objects")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    // MARK: - Detection Overlay
    private var detectionOverlay: some View {
        GeometryReader { geometry in
            ForEach(detections) { detection in
                DetectionBoxView(
                    detection: detection,
                    containerSize: geometry.size,
                    imageSize: selectedImage?.size
                )
                .onTapGesture {
                    handleDetectionTap(detection)
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: detections.count)
    }
    
    // MARK: - Control Bar
    private var controlBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 16) {
                // Action buttons - organized by mode with better styling
                Group {
                    if detectionMode == .camera {
                        // Camera capture mode buttons
                        HStack(spacing: 20) {
                            Spacer()
                            
                            // Camera capture button
                            Button(action: capturePhoto) {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(.white)
                                    .background(Color.appPrimary, in: Circle())
                                    .shadow(radius: 4)
                            }
                            .accessibilityLabel("Capture Photo")
                            
                            // Import photo button
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Import Photo")
                            .onChange(of: selectedPhotoItem) { _, newItem in
                                loadSelectedPhoto(newItem)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        // Photo mode buttons - icon only with better spacing
                        HStack(spacing: 20) {
                            Spacer()
                            
                            Button(action: clearPhoto) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Clear")
                            
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.borderedProminent)
                            .accessibilityLabel("Change Photo")
                            .onChange(of: selectedPhotoItem) { _, newItem in
                                loadSelectedPhoto(newItem)
                            }
                            
                            Button(action: capturePhoto) {
                                Image(systemName: "camera.fill")
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Capture Photo")
                            
                            if selectedImage != nil {
                                Button(action: rescanPhoto) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title3)
                                        .frame(width: 44, height: 44)
                                }
                                .buttonStyle(.bordered)
                                .accessibilityLabel("Rescan")
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: detectionMode)
            }
        }
        .background(.regularMaterial)
    }
    
    // MARK: - Methods
    private func capturePhoto() {
        // Check camera availability
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        // Check camera permission
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingCamera = true
                    }
                }
            }
        case .authorized:
            showingCamera = true
        default:
            // Show alert or handle denied permission
            print("Camera permission denied")
            break
        }
    }
    
    private func handleModeChange(from oldMode: DetectionMode, to newMode: DetectionMode) {
        // Clear detections when switching modes
        detections = []
    }
    
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        isProcessing = true
        
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                // Clear the selected photo item so it doesn't auto-select next time
                selectedPhotoItem = nil
                
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        selectedImage = image
                        runDetection(on: image)
                        detectionMode = .photo
                    }
                case .failure(let error):
                    print("Error loading photo: \(error)")
                }
                isProcessing = false
            }
        }
    }
    
    private func runDetection(on image: UIImage) {
        isProcessing = true
        detector.detect(in: image, confidenceThreshold: confidenceThreshold) { results in
            detections = results
            isProcessing = false
        }
    }
    
    private func clearPhoto() {
        withAnimation(.easeOut(duration: 0.25)) {
            selectedImage = nil
            detections = []
            capturedImage = nil
        }
    }
    
    private func rescanPhoto() {
        guard let image = selectedImage else { return }
        runDetection(on: image)
    }
    
    private func handleDetectionTap(_ detection: DetectionResult) {
        // Haptic feedback on tap
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Use the detection with the selected image
        selectedDetection = detection
    }
}

// MARK: - Detection Box View
struct DetectionBoxView: View {
    let detection: DetectionResult
    let containerSize: CGSize
    let imageSize: CGSize?
    
    var body: some View {
        let rect = calculateRect()
        
        ZStack(alignment: .topLeading) {
            // Bounding box with app theme color
            Rectangle()
                .stroke(Color.appDetectionBox, lineWidth: 3)
                .background(
                    Rectangle()
                        .fill(Color.appDetectionBox.opacity(0.15))
                )
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
            
            // Label with proper styling
            VStack(alignment: .leading, spacing: 4) {
                Text(detection.label.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appDetectionBox, in: RoundedRectangle(cornerRadius: 6))
                    .foregroundStyle(.white)
                
                Text(detection.confidencePercentage)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
                    .foregroundStyle(.primary)
            }
            .position(x: max(rect.minX + 50, 50), y: max(rect.minY - 20, 20))
        }
    }
    
    private func calculateRect() -> CGRect {
        let normalizedBox = detection.boundingBox
        
        // Determine the actual preview size
        let previewSize: CGSize
        if let imageSize = imageSize {
            // For photo mode, maintain aspect ratio
            let aspectRatio = imageSize.width / imageSize.height
            let containerAspect = containerSize.width / containerSize.height
            
            if aspectRatio > containerAspect {
                // Image is wider - fit to width
                previewSize = CGSize(width: containerSize.width, height: containerSize.width / aspectRatio)
            } else {
                // Image is taller - fit to height
                previewSize = CGSize(width: containerSize.height * aspectRatio, height: containerSize.height)
            }
        } else {
            // Use container size
            previewSize = containerSize
        }
        
        let x = normalizedBox.minX * previewSize.width
        let y = normalizedBox.minY * previewSize.height
        let width = normalizedBox.width * previewSize.width
        let height = normalizedBox.height * previewSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

#Preview {
    DetectView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
