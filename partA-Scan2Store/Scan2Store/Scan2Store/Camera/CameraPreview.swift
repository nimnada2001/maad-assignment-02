//
//  CameraPreview.swift
//  Scan2Store
//
//  SwiftUI wrapper for AVCaptureVideoPreviewLayer
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.setupPreviewLayer(with: session)
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        uiView.updateSession(session)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {}
}

// Custom UIView that handles preview layer layout
class CameraPreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPreviewLayer(with session: AVCaptureSession) {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.layer.addSublayer(layer)
        previewLayer = layer
    }
    
    func updateSession(_ session: AVCaptureSession) {
        if previewLayer?.session != session {
            previewLayer?.session = session
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}
