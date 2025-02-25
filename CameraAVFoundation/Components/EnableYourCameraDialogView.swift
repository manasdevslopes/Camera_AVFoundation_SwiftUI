//
//  EnableYourCameraDialogView.swift
//  CameraAVFoundation
//
//  Created by MANAS VIJAYWARGIYA on 25/02/25.
//

import SwiftUI

struct EnableYourCameraDialogView: View {
  var dismiss: () -> ()
  var goToSettings: () -> ()
  
  var body: some View {
    CustomDialogView(
      imageName: "camera.circle.fill",
      imageHeight: 50,
      headerText: "Enable your Camera",
      descriptionText: "Camera access denied. Please enable camera access in settings.",
      mainButtonText: "Enable",
      mainButtonAction: goToSettings,
      secondaryButtonText: "Cancel",
      secondaryButtonAction: dismiss
    )
  }
}
