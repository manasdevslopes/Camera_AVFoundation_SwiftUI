//
// CtaButton.swift
// CameraAVFoundation
//
// Created by MANAS VIJAYWARGIYA on 26/02/25.
// ------------------------------------------------------------------------
// Copyright © 2025 Blacenova. All rights reserved.
// ------------------------------------------------------------------------
//


import SwiftUI

fileprivate struct CtaButtonStyle: ButtonStyle {
  let backgroundColor: Color
  let foregroundColor: Color
  let isDisabled: Bool
  var verticalPadding: Double = 19
  var cornerRadius: CGFloat = 28
  
  func makeBody(configuration: Configuration) -> some View {
    let currentForegroundColor = configuration.isPressed ? foregroundColor.opacity(0.8) : foregroundColor
    let currentBackgroundColor = isDisabled ? Color(.gray) : configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor
    
    return configuration.label.padding(.vertical, verticalPadding)
      .foregroundStyle(currentForegroundColor).background(currentBackgroundColor)
      .cornerRadius(cornerRadius)
      .overlay(RoundedRectangle(cornerRadius: cornerRadius)
        .stroke(currentForegroundColor, lineWidth: 0.5))
      .font(.system(size: 14))
      .scaleEffect(configuration.isPressed ? 0.98 : 1)
  }
}

struct CtaButton: View {
  var backgroundColor: Color
  var foregroundColor: Color
  private let text: String
  private let systemImage: String
  private let action: () -> ()
  private let disabled: Bool
  private let verticlePadding: Double
  private let horizontalPadding: Double
  private var cornerRadius: CGFloat = 28
  private let fontSize: CGFloat
  private var feedbackType: FeedbackType
  
  init(text: String,
       systemImage: String,
       disabled: Bool = false,
       backgroundColor: Color = Color(.darkBlue),
       foregroundColor: Color = .white,
       verticlePadding: Double = 12,
       horizontalPadding: Double = 42.5,
       cornerRadius: CGFloat = 28,
       fontSize: CGFloat = 20,
       feedbackType: FeedbackType = .success,
       action: @escaping () -> Void) {
    self.text = text
    self.systemImage = systemImage
    self.disabled = disabled
    self.backgroundColor = backgroundColor
    self.foregroundColor = foregroundColor
    self.verticlePadding = verticlePadding
    self.horizontalPadding = horizontalPadding
    self.cornerRadius = cornerRadius
    self.fontSize = fontSize
    self.feedbackType = feedbackType
    self.action = action
  }
  
  var body: some View {
    Button {
      self.action()
      Feedback.trigger(feedbackType)
    } label: {
      Label(self.text, systemImage: systemImage)
        .font(.system(size: fontSize)).frame(maxWidth: .infinity)
    }
    .buttonStyle(
      CtaButtonStyle(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        isDisabled: disabled,
        verticalPadding: verticlePadding,
        cornerRadius: cornerRadius)
    )
    .disabled(self.disabled).padding(.horizontal, horizontalPadding)
  }
}

#Preview {
  CtaButton(text: "Hello, SwiftUI", systemImage: "camera.circle", action: { print("Hello, SwiftUI") })
}
