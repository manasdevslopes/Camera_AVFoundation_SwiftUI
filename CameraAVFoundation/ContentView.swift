//
//  ContentView.swift
//  CameraAVFoundation
//
//  Created by MANAS VIJAYWARGIYA on 25/02/25.
//

import SwiftUI

struct ContentView: View {
  @State private var openCamera: Bool = false
  @State private var capturedImage: UIImage?
  @State private var openQRScanner: Bool = false
  @State private var scannedText: String = ""
  
  var body: some View {
    VStack {
      if let image = capturedImage {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()  // Ensures the full image is visible
          .frame(width: 350, height: 250)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      } else {
        Text("No Image Captured").foregroundColor(.gray)
      }
      
      CtaButton(text: "Open Camera", systemImage: "camera.circle") {
        openCamera.toggle()
      }
      
      CtaButton(text: "Open QR Scanner", systemImage: "qrcode") {
        openQRScanner.toggle()
      }
      
      if !scannedText.isEmpty {
        Text(scannedText).font(.headline).bold().font(.system(size: 16))
      }
    }
    .padding()
    .fullScreenCover(isPresented: $openCamera) {
      CameraScanView(image: $capturedImage)
    }
    .fullScreenCover(isPresented: $openQRScanner) {
      QRScanView(scanResult: $scannedText)
    }
  }
}

#Preview {
  ContentView()
}
