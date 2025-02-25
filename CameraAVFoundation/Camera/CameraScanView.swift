//
//  CameraScanView.swift
//  CameraAVFoundation
//
//  Created by MANAS VIJAYWARGIYA on 25/02/25.
//

import SwiftUI

struct CameraScanView: View {
  @State private var discreteTrigger1 = 0
  @Environment(\.dismiss) var dismiss
  @StateObject private var cameraScanVM = CameraScanViewModel()
  @Binding var image: UIImage?
  
  var body: some View {
    VStack(spacing: 16) {
      ZStack {
        CameraPreview(session: cameraScanVM.captureSession)
          .onAppear { cameraScanVM.startCamera() }
          .onDisappear { cameraScanVM.stopCamera() }
          .ignoresSafeArea()
       
        translucentOverlay()
        
        overlayView()
        
        if cameraScanVM.showCameraPermissionAlert {
          EnableCameraDialogView()
        }
      }
      .ignoresSafeArea()
    }
    .background(Color(.darkGray))
    .onAppear {
      cameraScanVM.requestCameraPermission()
    }
    .onChange(of: cameraScanVM.onProcessedImage) { oldValue, newValue in
      if let data = newValue {
        image = UIImage(data: data)
        dismiss()
      }
    }
  }
}

#Preview {
  CameraScanView(image: .constant(UIImage()))
}

extension CameraScanView {
  @ViewBuilder
  fileprivate func translucentOverlay() -> some View {
    Color.black.opacity(0.7) // Apply a translucent overlay
      .mask {
        Rectangle() // Full screen rectangle
          .overlay {
            Rectangle() // Transparent rectangle in the center
              .frame(height: 250).padding(.horizontal, 30)
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
        Text("Capture Image").font(.system(size: 16)).foregroundStyle(Color.white)
      }
      .frame(maxWidth: .infinity)
      .overlay(alignment: .trailing) {
        Button {
          self.dismiss()
        } label: {
          Image(systemName: "xmark.app.fill").resizable().aspectRatio(contentMode: .fit)
            .frame(width: 41, height: 41).padding(.trailing, 16)
        }
        .foregroundStyle(.white)
      }
      
      Text("Place the object in below's rectangle and press 'Capture' to take a picture.")
        .font(.system(size: 16)).multilineTextAlignment(.center).padding(.horizontal, 30)
        .foregroundStyle(.white).padding(.top, 170)
      
      Spacer()
      
      Button {
        cameraScanVM.toggleFalsh()
        discreteTrigger1 += 1
      } label: {
        Image(systemName: cameraScanVM.isFlashOn ? "flashlight.slash.circle.fill" : "flashlight.off.circle.fill")
          .resizable().aspectRatio(contentMode: .fit).frame(width: 41, height: 41)
          .symbolEffect(
            .bounce,
            value: discreteTrigger1
          )
      }
      .padding(.bottom)
      .foregroundStyle(.white)
      
      Button {
        cameraScanVM.captureImage()
      } label: {
        Text("Capture").padding().frame(maxWidth: .infinity).frame(minHeight: 55)
          .background(.white).foregroundStyle(Color(.darkGray)).font(.system(size: 15))
          .cornerRadius(20)
      }
      .disabled(cameraScanVM.showLoadingToast)
      .padding(.horizontal, 32)
      Spacer().frame(height: 80)
    }
    .overlay {
      if cameraScanVM.showLoadingToast {
        ProgressView().controlSize(.extraLarge).tint(.white)
      }
    }
  }
  
  fileprivate func EnableCameraDialogView() -> some View {
    return EnableYourCameraDialogView {
      withAnimation {
        cameraScanVM.showCameraPermissionAlert = false
      }
    } goToSettings: {
      withAnimation {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        cameraScanVM.showCameraPermissionAlert = false
      }
    }
    .transition(.move(edge: .bottom)).zIndex(1)
    .offset(y: cameraScanVM.showCameraPermissionAlert ? 0 : UIScreen.main.bounds.height)
    .animation(.easeInOut(duration: 0.3), value: cameraScanVM.showCameraPermissionAlert)
  }
}
