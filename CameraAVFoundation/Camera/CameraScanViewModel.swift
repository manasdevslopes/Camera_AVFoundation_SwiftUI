//
//  CameraScanViewModel.swift
//  CameraAVFoundation
//
//  Created by MANAS VIJAYWARGIYA on 25/02/25.
//

import SwiftUI
import AVFoundation

class CameraScanViewModel: NSObject, ObservableObject {
  @Published var showLoadingToast: Bool = false
  @Published var isFlashOn: Bool = false
  @Published var showCameraPermissionAlert: Bool = false
  @Published var isCameraRunning: Bool = false
  @Published var onProcessedImage: Data?
  
  private(set) var captureSession = AVCaptureSession()
  private var photoOutput = AVCapturePhotoOutput()
  
  override init() {
    super.init()
    startCameraSession()
  }
  
  private func startCameraSession() {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      captureSession.addOutput(photoOutput)
    } catch {
      debugPrint("Camera setup error: \(error.localizedDescription)")
    }
  }
  
  @MainActor
  func requestCameraPermission() {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    switch status {
      case .restricted, .denied:
        showCameraPermissionAlert = true
        isCameraRunning = false
      case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { granted in
          Task {@MainActor in
            self.showCameraPermissionAlert = !granted
            self.isCameraRunning = granted
          }
        }
      case .authorized:
        isCameraRunning = true
        showCameraPermissionAlert = false
      @unknown default: break
    }
  }
}

// MARK: - Start & Stop Camera
extension CameraScanViewModel {
  func startCamera() {
    DispatchQueue.global(qos: .background).async {
      self.captureSession.startRunning()
    }
  }
  
  func stopCamera() {
    guard captureSession.isRunning else { return }
    captureSession.stopRunning()
    isCameraRunning = false
  }
}

// MARK: - Flash & Capture Image
extension CameraScanViewModel {
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
  
  func captureImage() {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    if status == .restricted || status == .denied {
      DispatchQueue.main.async {
        withAnimation {
          self.showCameraPermissionAlert = true
        }
      }
      return
    }
    
    let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
    guard !discovery.devices.isEmpty else { return }
    
    let photoSettings = AVCapturePhotoSettings()
    if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
      photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
    }
    photoOutput.capturePhoto(with: photoSettings, delegate: self)
  }
}

// MARK: - Process & crop
extension CameraScanViewModel {
  @MainActor
  private func processCapturedImage(_ imageData: Data) async {
    showLoadingToast = true
    defer { showLoadingToast = false }
    
    guard let croppedImage = cropImage(data: imageData) else { return }
    self.onProcessedImage = croppedImage
  }
  
  private func cropImage(data: Data) -> Data? {
    guard let originalImage = UIImage(data: data), let cgImage = originalImage.cgImage else { return nil }
    
    // Get the screen and camera dimensions
    let screenSize = UIScreen.main.bounds.size
    let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
    
    // Center the scale ratios between screen and image dimensions
    let widthScale = imageSize.width / screenSize.width
    let heightScale = imageSize.height / screenSize.height
    
    // Calculate the crop dimensions based on the scaled width and height
    let cropWidth = (screenSize.width - 32) * widthScale
    let cropHeight = 250 * heightScale
    
    // Center the crop rectangle on the captured image
    let originX = (imageSize.width - cropWidth) / 2
    let originY = (imageSize.height - cropHeight) / 2
    
    let cropRect = CGRect(x: originX, y: originY, width: cropWidth, height: cropHeight)
    
    // Performing cropping
    guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
    return UIImage(cgImage: croppedCGImage, scale: originalImage.scale, orientation: .right).jpegData(compressionQuality: 1.0)
  }
}

// MARK: - AVFoundation Photo Capture Delegate method
extension CameraScanViewModel: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
    guard let imageData = photo.fileDataRepresentation() else { return }
    Task { await processCapturedImage(imageData) }
  }
}
