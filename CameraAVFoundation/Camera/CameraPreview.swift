//
// CameraPreview.swift
// CameraAVFoundation
//
// Created by MANAS VIJAYWARGIYA on 25/02/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
  let session: AVCaptureSession
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = .resizeAspectFill
    previewLayer.frame = UIScreen.main.bounds
    view.layer.addSublayer(previewLayer)
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) { }
}
