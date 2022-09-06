//
//  UIImage+extensions.swift
//  MLCustomFilter
//
//  Created by Srikanth SP on 05/09/22.
//

import Foundation
import UIKit

extension UIImage {
  func saveImage(path: URL) -> URL? {
    guard
      let data = self.jpegData(compressionQuality: 0.8),
      (try? data.write(to: path)) != nil
    else {
      return nil
    }
    return path
  }
  convenience init?(withCVImageBuffer cvImageBuffer: CVImageBuffer) {
    let ciImage = CIImage(cvImageBuffer: cvImageBuffer)
    let context = CIContext.init(options: nil)
    guard
      let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
    else {
      return nil
    }
    self.init(cgImage: cgImage)
  }
  func upOrientationImage() -> UIImage? {
    switch imageOrientation {
    case .up:
      return self
    default:
      UIGraphicsBeginImageContextWithOptions(size, false, scale)
      draw(in: CGRect(origin: .zero, size: size))
      let result = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return result
    }
  }
}
