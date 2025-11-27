//
//  YOLODetector.swift
//  Scan2Store
//
//  CoreML + Vision integration for YOLOv3FP16 object detection
//

import UIKit
import CoreML
import Vision
import CoreGraphics
import Combine

class YOLODetector: ObservableObject {
    private var model: VNCoreMLModel?
    private var request: VNCoreMLRequest?
    
    // COCO class labels (80 classes)
    private let cocoLabels = [
        "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat",
        "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat", "dog", "horse",
        "sheep", "cow", "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella", "handbag", "tie",
        "suitcase", "frisbee", "skis", "snowboard", "sports ball", "kite", "baseball bat", "baseball glove",
        "skateboard", "surfboard", "tennis racket", "bottle", "wine glass", "cup", "fork", "knife", "spoon",
        "bowl", "banana", "apple", "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut",
        "cake", "chair", "couch", "potted plant", "bed", "dining table", "toilet", "tv", "laptop", "mouse",
        "remote", "keyboard", "cell phone", "microwave", "oven", "toaster", "sink", "refrigerator", "book",
        "clock", "vase", "scissors", "teddy bear", "hair drier", "toothbrush"
    ]
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3FP16", withExtension: "mlmodelc") ??
                Bundle.main.url(forResource: "YOLOv3FP16", withExtension: "mlmodel") else {
            print("Error: YOLOv3FP16 model not found")
            return
        }
        
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            model = try VNCoreMLModel(for: mlModel)
            
            request = VNCoreMLRequest(model: model!) { request, error in
                if let error = error {
                    print("Vision request error: \(error)")
                }
            }
            
            // Configure request for optimal performance
            request?.imageCropAndScaleOption = .scaleFill
            
        } catch {
            print("Error loading model: \(error)")
        }
    }
    
    /// Run detection on an image
    /// - Parameters:
    ///   - image: Input image
    ///   - confidenceThreshold: Minimum confidence to include (0.0-1.0)
    ///   - completion: Completion handler with detection results
    func detect(in image: UIImage, confidenceThreshold: Double = 0.5, completion: @escaping ([DetectionResult]) -> Void) {
        guard let cgImage = image.cgImage,
              let request = request else {
            completion([])
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }
                
                let detections = self.processObservations(
                    results,
                    imageSize: image.size,
                    confidenceThreshold: confidenceThreshold,
                    sourceImage: image
                )
                
                DispatchQueue.main.async {
                    completion(detections)
                }
            } catch {
                print("Detection error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    /// Process Vision observations into DetectionResult objects
    private func processObservations(
        _ observations: [VNRecognizedObjectObservation],
        imageSize: CGSize,
        confidenceThreshold: Double,
        sourceImage: UIImage
    ) -> [DetectionResult] {
        var detections: [DetectionResult] = []
        
        for observation in observations {
            guard observation.confidence >= Float(confidenceThreshold) else { continue }
            
            // Get top label
            guard let topLabel = observation.labels.first else { continue }
            let label = topLabel.identifier
            let confidence = Double(topLabel.confidence)
            
            // Convert bounding box (Vision uses bottom-left origin, UIKit uses top-left)
            let boundingBox = observation.boundingBox
            let normalizedBox = CGRect(
                x: boundingBox.minX,
                y: 1.0 - boundingBox.maxY, // Flip Y coordinate
                width: boundingBox.width,
                height: boundingBox.height
            )
            
            // Crop the detected object from the image
            let croppedImage = ImageCropper.crop(image: sourceImage, to: normalizedBox)
            
            let detection = DetectionResult(
                label: label,
                confidence: confidence,
                boundingBox: normalizedBox,
                croppedUIImage: croppedImage
            )
            
            detections.append(detection)
        }
        
        // Apply Non-Maximum Suppression to remove duplicates
        return NMS.performNMS(on: detections, iouThreshold: 0.5)
    }
    
    /// Run detection on a pixel buffer (for camera frames)
    /// - Parameters:
    ///   - pixelBuffer: Camera frame pixel buffer
    ///   - orientation: Image orientation
    ///   - confidenceThreshold: Minimum confidence threshold
    ///   - completion: Completion handler with detection results
    func detect(
        in pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation = .up,
        confidenceThreshold: Double = 0.5,
        completion: @escaping ([DetectionResult]) -> Void
    ) {
        guard let request = request else {
            completion([])
            return
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }
                
                // For camera frames, we can't crop easily, so pass nil for source image
                var detections: [DetectionResult] = []
                
                for observation in results {
                    guard observation.confidence >= Float(confidenceThreshold) else { continue }
                    
                    guard let topLabel = observation.labels.first else { continue }
                    let label = topLabel.identifier
                    let confidence = Double(topLabel.confidence)
                    
                    let boundingBox = observation.boundingBox
                    let normalizedBox = CGRect(
                        x: boundingBox.minX,
                        y: 1.0 - boundingBox.maxY,
                        width: boundingBox.width,
                        height: boundingBox.height
                    )
                    
                    let detection = DetectionResult(
                        label: label,
                        confidence: confidence,
                        boundingBox: normalizedBox,
                        croppedUIImage: nil // Will crop when user selects
                    )
                    
                    detections.append(detection)
                }
                
                let filtered = NMS.performNMS(on: detections, iouThreshold: 0.5)
                
                DispatchQueue.main.async {
                    completion(filtered)
                }
            } catch {
                print("Detection error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}

