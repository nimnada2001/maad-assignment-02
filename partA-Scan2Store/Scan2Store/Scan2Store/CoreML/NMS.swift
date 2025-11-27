//
//  NMS.swift
//  Scan2Store
//
//  Non-Maximum Suppression implementation for removing duplicate detections
//

import Foundation
import CoreGraphics

struct NMS {
    /// Performs Non-Maximum Suppression on detection results
    /// - Parameters:
    ///   - detections: Array of detection results with bounding boxes
    ///   - iouThreshold: Intersection over Union threshold (default: 0.5)
    /// - Returns: Filtered array of detections with duplicates removed
    static func performNMS(on detections: [DetectionResult], iouThreshold: Double = 0.5) -> [DetectionResult] {
        guard !detections.isEmpty else { return [] }
        
        // Sort by confidence (highest first)
        let sorted = detections.sorted { $0.confidence > $1.confidence }
        var selected: [DetectionResult] = []
        var suppressed = Set<Int>()
        
        for i in 0..<sorted.count {
            if suppressed.contains(i) { continue }
            
            let current = sorted[i]
            selected.append(current)
            
            // Suppress overlapping boxes
            for j in (i + 1)..<sorted.count {
                if suppressed.contains(j) { continue }
                
                let other = sorted[j]
                let iou = calculateIoU(box1: current.boundingBox, box2: other.boundingBox)
                
                if iou > iouThreshold {
                    suppressed.insert(j)
                }
            }
        }
        
        return selected
    }
    
    /// Calculate Intersection over Union (IoU) between two bounding boxes
    private static func calculateIoU(box1: CGRect, box2: CGRect) -> Double {
        let intersection = box1.intersection(box2)
        let intersectionArea = Double(intersection.width * intersection.height)
        
        let box1Area = Double(box1.width * box1.height)
        let box2Area = Double(box2.width * box2.height)
        let unionArea = box1Area + box2Area - intersectionArea
        
        guard unionArea > 0 else { return 0 }
        return intersectionArea / unionArea
    }
}

