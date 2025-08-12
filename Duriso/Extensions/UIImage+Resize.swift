//
//  UIImage+Resize.swift
//  Duriso
//
//  Created by 김동현 on 9/28/24.
//

import UIKit

extension UIImage {
  func resized(to size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    defer { UIGraphicsEndImageContext() }
    
    draw(in: CGRect(origin: .zero, size: size))
    
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  func resized(withPercentage percentage: CGFloat) -> UIImage? {
    let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: canvasSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  func resized(toWidth width: CGFloat) -> UIImage? {
    let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: canvasSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
