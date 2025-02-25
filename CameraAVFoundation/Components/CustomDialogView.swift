//
//  CustomDialogView.swift
//  CameraAVFoundation
//
//  Created by MANAS VIJAYWARGIYA on 25/02/25.
//

import SwiftUI

struct CustomDialogView: View {
  var imageName: String
  var imageHeight: CGFloat = 60
  var imagePaddingTop: CGFloat = 35
  var headerText: String = "No Title"
  var headerTextFontSize: CGFloat = 16
  var headerTextColor: Color = .black
  var headerTextTopPadding: CGFloat = 35
  var headerTextHorizontalPadding: CGFloat = 20
  var descriptionText: String = "No Description"
  var descriptionTextFontSize: CGFloat = 14
  var descriptionTextColor: Color = .black
  var descriptionTextTopPadding: CGFloat = 14
  var descriptionTextHorizontalPadding: CGFloat = 20
  var buttonsRowHeight: CGFloat = 53
  var mainButtonText: String
  var mainButtonTextFontSize: CGFloat = 14
  var mainButtonTextColor: Color = Color(.darkGray)
  var mainButtonAction: (() -> ())
  var secondaryButtonText: String
  var secondaryButtonTextFontSize: CGFloat = 14
  var secondaryButtonTextColor: Color = Color(.darkGray)
  var secondaryButtonAction: (() -> ()) = {}
  var horizontalDialogPadding: CGFloat = UIScreen.main.bounds.size.width * 0.15
  
  var body: some View {
    ZStack {
      Color.black.opacity(0.7).ignoresSafeArea()
      VStack(alignment: .center, spacing: 0) {
        Image(systemName: imageName).resizable().aspectRatio(contentMode: .fit).frame(width: imageHeight, height: imageHeight)
          .padding(.top, imagePaddingTop)
        Text(headerText).font(.system(size: headerTextFontSize)).bold().foregroundStyle(headerTextColor).multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true).lineSpacing(3).padding(.top, headerTextTopPadding)
          .padding(.horizontal, headerTextHorizontalPadding)
        Text(descriptionText).font(.system(size: descriptionTextFontSize)).bold().foregroundStyle(descriptionTextColor).multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true).lineSpacing(3).padding(.top, descriptionTextTopPadding)
          .padding(.horizontal, descriptionTextHorizontalPadding)
        Divider().background(Color(.darkGray)).padding(.top, 24)
        HStack(spacing: 0) {
          Button {
            secondaryButtonAction()
          } label: {
            Text(secondaryButtonText).font(.system(size: secondaryButtonTextFontSize)).fontWeight(.regular).foregroundStyle(secondaryButtonTextColor)
              .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
              .padding(.horizontal, 12).background(.white)
          }
          .buttonStyle(PlainButtonStyle()).frame(maxWidth: .infinity)
          
          Divider().background(Color(.darkGray))
          
          Button {
            mainButtonAction()
          } label: {
            Text(mainButtonText).font(.system(size: mainButtonTextFontSize)).fontWeight(.regular).foregroundStyle(mainButtonTextColor)
              .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
              .padding(.horizontal, 12).background(.white)
          }
          .buttonStyle(PlainButtonStyle()).frame(maxWidth: .infinity)
        }
        .frame(height: buttonsRowHeight)
      }
      .background(Color.white).cornerRadius(8).padding(.horizontal, horizontalDialogPadding)
    }
  }
}
