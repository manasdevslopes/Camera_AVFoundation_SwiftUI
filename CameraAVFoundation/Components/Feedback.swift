//
// Feedback.swift
// CameraAVFoundation
//
// Created by MANAS VIJAYWARGIYA on 26/02/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//
    

import SwiftUI

enum FeedbackType {
  case success, warning, error
}

struct Feedback {
  static func trigger(_ type: FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    switch type {
      case .success:
        generator.notificationOccurred(.success)
      case .warning:
        generator.notificationOccurred(.warning)
      case .error:
        generator.notificationOccurred(.error)
    }
  }
}
