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
  
  var captureSession = AVCaptureSession()
  private var photoOutput = AVCapturePhotoOutput()
  
  override init() {
    super.init()
    startCameraSession()
  }
  
  func startCameraSession() {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      captureSession.addOutput(photoOutput)
    } catch {
      debugPrint("Camera setup error: \(error.localizedDescription)")
    }
  }
  
  func requestCameraPermission() {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    switch status {
      case .restricted, .denied:
        showCameraPermissionAlert = true
        isCameraRunning = false
      case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { granted in
          if !granted {
            DispatchQueue.main.async {
              self.showCameraPermissionAlert = true
              self.isCameraRunning = false
            }
          } else if granted {
            self.isCameraRunning = true
            self.showCameraPermissionAlert = false
          }
        }
      case .authorized:
        isCameraRunning = true
        showCameraPermissionAlert = false
      default: break
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
    captureSession.stopRunning()
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
    
    let discovery = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
    guard !discovery.devices.isEmpty else { return }
    
    let photoSettings = AVCapturePhotoSettings()
    if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
      photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
      photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
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
    guard let cgImage = UIImage(data: data)?.cgImage else { return nil }
    
    // Get the screen and camera dimensions
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let imageWidth = CGFloat(cgImage.width)
    let imageHeight = CGFloat(cgImage.height)
    
    // Center the scale ratios between screen and image dimensions
    let widthScale = imageWidth / screenWidth
    let heightScale = imageHeight / screenHeight
    
    // Calculate the crop dimensions based on the scaled width and height
    let cropWidth = (screenWidth - 32) * widthScale
    let cropHeight = 250 * heightScale
    
    // Center the crop rectangle on the captured image
    let originX = (imageWidth - cropWidth) / 2
    let originY = (imageHeight - cropHeight) / 2
    
    let cropRect = CGRect(x: originX, y: originY, width: cropWidth, height: cropHeight)
    
    // Performing cropping
    let croppedImage = cgImage.cropping(to: cropRect)
    return UIImage(cgImage: croppedImage!, scale: 1.0, orientation: .right).jpegData(compressionQuality: 1.0)
  }
}

// MARK: - AVFoundation Photo Capture Delegate method
extension CameraScanViewModel: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
    guard let imageData = photo.fileDataRepresentation() else { return }
    Task { await processCapturedImage(imageData) }
  }
}
