//
// CameraQRPreview.swift
// CameraAVFoundation
//
// Created by MANAS VIJAYWARGIYA on 26/02/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

struct CameraQRPreview: UIViewControllerRepresentable {
  @ObservedObject var viewModel: QRScanViewModel
  
  func makeUIViewController(context: Context) -> CameraPreviewController {
    return CameraPreviewController(viewModel: viewModel)
  }
  
  func updateUIViewController(_ uiViewController: CameraPreviewController, context: Context) { }
}

class CameraPreviewController: UIViewController {
  var viewModel: QRScanViewModel
  
  init(viewModel: QRScanViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Here we can access the previewLayer directly from the viewModel
    if let previewLayer = viewModel.previewLayer {
      previewLayer.frame = view.bounds
      view.layer.addSublayer(previewLayer)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // Stop the camera session when the view disappears
    viewModel.stopScanning()
  }
}
