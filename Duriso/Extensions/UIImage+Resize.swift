//
//  UIImage+Resize.swift
//  Duriso
//
//  Created by 김동현 on 9/28/24.
//

import UIKit

extension UIImage {
  /// CGSize 값을 통한 UIImage Resize Extension
  /// - Parameter size: Resize 하려는 CGSize 값
  /// - Returns: Resize 된 이미지
  func resized(to size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    defer { UIGraphicsEndImageContext() }
    
    draw(in: CGRect(origin: .zero, size: size))
    
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
  /// Percent 값을 통한 UIImage Resize Extension
  /// - Parameter percentage: Resize 하려는 percent 값
  /// - Returns: Resize 된 이미지
  func resized(withPercentage percentage: CGFloat) -> UIImage? {
    let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: canvasSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
  /// Width 값을 통한 UIImage Resize Extension
  /// - Parameter width: Resize 하려는 width 값
  /// - Returns: Resize 된 이미지
  func resized(toWidth width: CGFloat) -> UIImage? {
    let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: canvasSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
