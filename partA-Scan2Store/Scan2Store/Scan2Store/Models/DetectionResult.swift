//
//  DetectionResult.swift
//  Scan2Store
//
//  Represents a single object detection result from YOLO model
//

import UIKit
import CoreGraphics

struct DetectionResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double
    let boundingBox: CGRect // Normalized coordinates (0-1)
    let croppedUIImage: UIImage?
    
    // Computed property for confidence percentage string
    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
}

