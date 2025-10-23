//
// QRScanViewModel.swift
// CameraAVFoundation
//
// Created by MANAS VIJAYWARGIYA on 26/02/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI
import AVFoundation

class QRScanViewModel: NSObject, ObservableObject {
  @Published var showLoadingToast: Bool = false
  @Published var isFlashOn: Bool = false
  @Published var showCameraPermissionAlert: Bool = false
  @Published var qrCodeFrame: CGRect = .zero
  @Published var scanResult: String?
  
  private(set) var captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer?
  private var captureMetaDataOutput = AVCaptureMetadataOutput()
  
  override init() {
    super.init()
    setupCamera()
  }
  
  private func setupCamera() {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
    
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      
      let metadataOutput = AVCaptureMetadataOutput()
      captureSession.addOutput(metadataOutput)
      
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = [.qr]
      
      previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      previewLayer?.videoGravity = .resizeAspectFill
      
      // You can use the preview layer's frame directly in the SwiftUI CameraPreviewView
      DispatchQueue.global(qos: .background).async {
        self.captureSession.startRunning()
      }
    } catch {
      debugPrint("Camera setup error: \(error.localizedDescription)")
    }
  }
  
  func stopScanning() {
    captureSession.stopRunning() // Stop the camera session when not needed
    previewLayer?.removeFromSuperlayer() // Remove the preview layer
  }
}

// MARK: - Request Camera Permission
extension QRScanViewModel {
  @MainActor
  func requestCameraPermission() {
//    AVCaptureDevice.requestAccess(for: .video) { granted in
//      DispatchQueue.main.async {
//        withAnimation {
//          self.showCameraPermissionAlert = !granted
//        }
//      }
//    }
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    switch status {
      case .restricted, .denied: showCameraPermissionAlert = true
      case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { granted in
          if !granted {
            self.showCameraPermissionAlert = true
          } else if granted {
            self.showCameraPermissionAlert = false
          }
        }
      case .authorized: showCameraPermissionAlert = false
      default: break
    }
  }
}

// MARK: - AVCapture Metadata Extension
extension QRScanViewModel: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    guard let metadataObject = metadataObjects.first,
    let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
    let stringValue = readableObject.stringValue else {
      DispatchQueue.main.async { self.qrCodeFrame = .zero }
      return
    }
    
    // Update the frame of the QR code
    if let qrCodeObject = previewLayer?.transformedMetadataObject(for: readableObject) {
      self.qrCodeFrame = qrCodeObject.bounds
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.scanResult = stringValue
    }
  }
}

// MARK: - Flash
extension QRScanViewModel {
  func toggleFalsh() {
    guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
    
    do {
      try device.lockForConfiguration()
      device.torchMode = isFlashOn ? .off : .on
      isFlashOn.toggle()
      if device.torchMode == .on {
        do {
          try device.setTorchModeOn(level: 1.0)
        } catch {
          debugPrint(error)
        }
      }
      device.unlockForConfiguration()
    } catch {
      debugPrint("Failed to toggle flash mode: \(error)")
    }
  }
}
