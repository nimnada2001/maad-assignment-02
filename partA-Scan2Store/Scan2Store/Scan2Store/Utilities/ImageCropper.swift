//
//  ImageCropper.swift
//  Scan2Store
//
//  Utility for cropping images based on normalized bounding boxes
//

import UIKit
import CoreGraphics

struct ImageCropper {
    /// Crop an image to a normalized bounding box (0-1 coordinates)
    /// - Parameters:
    ///   - image: Source image
    ///   - normalizedRect: Normalized bounding box (x, y, width, height in 0-1 range)
    /// - Returns: Cropped image or nil if cropping fails
    static func crop(image: UIImage, to normalizedRect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        // Convert normalized coordinates to pixel coordinates
        let x = normalizedRect.minX * imageWidth
        let y = normalizedRect.minY * imageHeight
        let width = normalizedRect.width * imageWidth
        let height = normalizedRect.height * imageHeight
        
        // Ensure coordinates are within image bounds
        let cropRect = CGRect(
            x: max(0, x),
            y: max(0, y),
            width: min(width, imageWidth - max(0, x)),
            height: min(height, imageHeight - max(0, y))
        )
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    /// Crop from a specific point in a view's coordinate system
    static func crop(image: UIImage, from viewBounds: CGRect, cropRect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let scaleX = CGFloat(cgImage.width) / viewBounds.width
        let scaleY = CGFloat(cgImage.height) / viewBounds.height
        
        let x = cropRect.minX * scaleX
        let y = cropRect.minY * scaleY
        let width = cropRect.width * scaleX
        let height = cropRect.height * scaleY
        
        let imageCropRect = CGRect(x: x, y: y, width: width, height: height)
        
        guard let croppedCGImage = cgImage.cropping(to: imageCropRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

