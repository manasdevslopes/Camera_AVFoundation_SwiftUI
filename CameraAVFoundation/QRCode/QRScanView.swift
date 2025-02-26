//
// QRScanView.swift
// CameraAVFoundation
//
// Created by MANAS VIJAYWARGIYA on 26/02/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//


import SwiftUI

struct QRScanView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var qrScanVM: QRScanViewModel = .init()
  @State private var discreteTrigger1 = 0
  @Binding var scanResult: String
  
  var body: some View {
    VStack(spacing: 16) {
      ZStack {
        CameraQRPreview(viewModel: qrScanVM)
          .onDisappear { qrScanVM.stopScanning() }
          .ignoresSafeArea()
        
        translucentOverlay()
        
        overlayView()
        
        // This view will overlay the QR code frame on top of the camera preview
        Rectangle()
          .strokeBorder(Color(.mehendiGreen), lineWidth: 2)
          .frame(width: qrScanVM.qrCodeFrame.width, height: qrScanVM.qrCodeFrame.height)
          .position(x: qrScanVM.qrCodeFrame.midX, y: qrScanVM.qrCodeFrame.midY)
          .opacity(qrScanVM.qrCodeFrame.isEmpty ? 0 : 1)
        
        if qrScanVM.showCameraPermissionAlert {
          EnableCameraDialogView()
        }
      }
      .ignoresSafeArea()
    }
    .background(Color(.darkGray))
    .onAppear {
      qrScanVM.requestCameraPermission()
    }
    .onChange(of: qrScanVM.scanResult) { oldValue, newValue in
      if let dataString = newValue {
        scanResult = dataString
        dismiss()
      }
    }
  }
}

#Preview {
  QRScanView(scanResult: .constant(""))
}

extension QRScanView {
  @ViewBuilder
  fileprivate func translucentOverlay() -> some View {
    Color.black.opacity(0.8) // Apply a translucent overlay
      .mask {
        Rectangle() // Full screen rectangle
          .overlay {
            Rectangle() // Transparent rectangle in the center
              .frame(height: 300).padding(.horizontal, 30)
              .blendMode(.destinationOut)
          }
      }
  }
  
  @ViewBuilder
  fileprivate func overlayView() -> some View {
    // Overlay for the text and button
    VStack {
      Spacer().frame(height: 60)
      HStack {
        Text("Scan QR-code").font(.system(size: 16)).foregroundStyle(Color.white)
      }
      .frame(maxWidth: .infinity)
      .overlay(alignment: .trailing) {
        Button {
          self.dismiss()
          Feedback.trigger(.warning)
        } label: {
          Image(systemName: "xmark.app.fill").resizable().aspectRatio(contentMode: .fit)
            .frame(width: 42, height: 42).padding(.trailing, 16)
        }
        .foregroundStyle(.white)
      }
      
      Text("Hold up the camera over the QR-code of the charging station.")
        .font(.system(size: 16)).multilineTextAlignment(.center)
        .padding(.horizontal, 30).foregroundStyle(.white).padding(.top, 120)
      
      Spacer()
      
      Button {
        qrScanVM.toggleFalsh()
        discreteTrigger1 += 1
        Feedback.trigger(.success)
      } label: {
        Image(systemName: qrScanVM.isFlashOn ? "flashlight.slash.circle.fill" : "flashlight.off.circle.fill")
          .resizable().aspectRatio(contentMode: .fit).frame(width: 42, height: 42)
          .symbolEffect(.bounce, value: discreteTrigger1)
      }
      .padding(.bottom)
      .foregroundStyle(.white)
      
      Spacer().frame(height: 80)
    }
  }
  
  fileprivate func EnableCameraDialogView() -> some View {
    return EnableYourCameraDialogView {
      withAnimation {
        qrScanVM.showCameraPermissionAlert = false
      }
    } goToSettings: {
      withAnimation {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        qrScanVM.showCameraPermissionAlert = false
      }
    }
    .transition(.move(edge: .bottom)).zIndex(1)
    .offset(y: qrScanVM.showCameraPermissionAlert ? 0 : UIScreen.main.bounds.height)
    .animation(.easeInOut(duration: 0.3), value: qrScanVM.showCameraPermissionAlert)
  }
}
