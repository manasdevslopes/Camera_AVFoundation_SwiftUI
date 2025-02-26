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
    }
    .padding()
    .fullScreenCover(isPresented: $openCamera) {
      CameraScanView(image: $capturedImage)
    }
  }
}

#Preview {
  ContentView()
}
