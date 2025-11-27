//
//  CameraManager.swift
//  Scan2Store
//
//  Manages AVFoundation camera session for live detection
//

import AVFoundation
import UIKit
import CoreImage
import Combine

class CameraManager: NSObject, ObservableObject {
    // The capture session is a long-lived object; it does not need to be @Published.
    // Publishing it can cause SwiftUI "Publishing changes from within view updates" warnings
    // when inputs/outputs are mutated during configuration.
    let session = AVCaptureSession()
    
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var isSessionRunning = false
    
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    var onFrameCaptured: ((CVPixelBuffer) -> Void)?
    private var latestFrame: CVPixelBuffer?
    private let frameLock = NSLock()
    private let configLock = NSLock()
    private var isConfiguring = false
    private var shouldStartAfterConfig = false
    
    override init() {
        super.init()
        checkPermission()
    }
    
    func checkPermission() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                    if granted {
                        self?.setupSession(shouldStart: true)
                    }
                }
            }
        case .authorized:
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                if self.session.inputs.isEmpty {
                    self.setupSession(shouldStart: true)
                } else {
                    // Session already set up, just start it
                    self.startSessionInternal()
                }
            }
        default:
            break
        }
    }
    
    private func setupSession(shouldStart: Bool = false) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Prevent multiple simultaneous configurations - thread-safe check
            self.configLock.lock()
            if self.isConfiguring {
                if shouldStart {
                    self.shouldStartAfterConfig = true
                }
                self.configLock.unlock()
                return
            }
            self.isConfiguring = true
            self.shouldStartAfterConfig = shouldStart
            self.configLock.unlock()
            
            // Stop session if running before reconfiguration
            if self.session.isRunning {
                self.session.stopRunning()
            }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            
            // Remove existing inputs/outputs
            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }
            
            // Setup camera input
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.session.canAddInput(videoInput) else {
                self.session.commitConfiguration()
                self.configLock.lock()
                self.isConfiguring = false
                self.shouldStartAfterConfig = false
                self.configLock.unlock()
                return
            }
            
            self.session.addInput(videoInput)
            
            // Setup video output
            self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.queue"))
            self.videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }
            
            // IMPORTANT: Commit configuration BEFORE checking if we should start
            self.session.commitConfiguration()
            
            // Update state flags AFTER commit - must happen before any start attempts
            self.configLock.lock()
            let shouldStartNow = self.shouldStartAfterConfig
            // Clear configuring flag BEFORE unlocking to prevent race conditions
            self.isConfiguring = false
            self.shouldStartAfterConfig = false
            self.configLock.unlock()
            
            // Start session after configuration is complete if requested
            // We're already on sessionQueue, and commitConfiguration() is synchronous
            // so it's safe to start directly
            if shouldStartNow {
                self.startSessionInternal()
            }
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            self?.startSessionInternal()
        }
    }
    
    private func startSessionInternal() {
        // Check if configuration is in progress - thread-safe
        configLock.lock()
        let currentlyConfiguring = isConfiguring
        if currentlyConfiguring {
            shouldStartAfterConfig = true
            configLock.unlock()
            return
        }
        configLock.unlock()
        
        guard !session.isRunning else { return }
        
        // Ensure we're not in a configuration state
        guard !session.isInterrupted else { return }
        
        // Start the session - commitConfiguration() is synchronous, so once we pass the check above, we're safe
        session.startRunning()
        
        DispatchQueue.main.async { [weak self] in
            self?.isSessionRunning = self?.session.isRunning ?? false
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Cancel pending start if configuration is happening
            self.shouldStartAfterConfig = false
            
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Store latest frame for cropping
        frameLock.lock()
        latestFrame = pixelBuffer
        frameLock.unlock()
        
        // Deliver frames to the main queue asynchronously to avoid publishing changes during view updates
        if let onFrameCaptured = self.onFrameCaptured {
            DispatchQueue.main.async {
                onFrameCaptured(pixelBuffer)
            }
        }
    }
    
    /// Get the latest captured frame as UIImage (for cropping)
    func getLatestFrameAsImage() -> UIImage? {
        frameLock.lock()
        defer { frameLock.unlock() }
        
        guard let pixelBuffer = latestFrame else { return nil }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: .right) // Camera is typically rotated
    }
}
