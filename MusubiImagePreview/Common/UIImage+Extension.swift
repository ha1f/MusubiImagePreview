//
//  UIImage+Extension.swift
//  MusubiImagePreview
//
//  Created by ST20591 on 2017/12/29.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import Foundation

import UIKit

extension CGSize {
    func scaled(by scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
}

extension CIImage {
    /// Extract or generate CIImage
    /// If the UIImage is build from CGImage, ciImage is nil.
    /// https://developer.apple.com/documentation/uikit/uiimage/1624129-ciimage
    /// If so, we must build by CIImage(image:_).
    ///
    /// - parameter image: UIImage from which you want to get CIImage
    ///
    /// - returns: Generated CIImage
    static func extractOrGenerate(from image: UIImage) -> CIImage? {
        return image.ciImage ?? CIImage(image: image)
    }
    
    func resized(to size: CGSize) -> CIImage? {
        let xScale = size.width / extent.width
        let yScale = size.height / extent.height
        return transformed(by: CGAffineTransform(scaleX: xScale, y: yScale))
    }
    
    func asUIImage(scale: CGFloat = UIScreen.main.scale, orientation: UIImageOrientation = .up) -> UIImage {
        return UIImage(ciImage: self, scale: scale, orientation: orientation)
    }
}

extension UIImage {
    func aspectResized(to size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // keep aspect ratio
        let targetScale = scale * min(size.width / self.size.width, size.height / self.size.height)
        let scaledSize = size.scaled(by: targetScale)
        guard let ciImage = CIImage.extractOrGenerate(from: self)?.resized(to: scaledSize) else {
            return nil
        }
        return ciImage.asUIImage()
    }
    
    static func cross(size: CGSize, lineWidth: CGFloat, color: CGColor = UIColor.white.cgColor, edgeInset: UIEdgeInsets = .zero) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            let cgContext = context.cgContext
            
            cgContext.setLineCap(CGLineCap.square)
            cgContext.setLineWidth(lineWidth)
            cgContext.setStrokeColor(color)
            cgContext.setFillColor(color)
            
            let inset: CGFloat = lineWidth / sqrt(2)
            
            let leftEdge = edgeInset.left + inset
            let rightEdge = size.width - edgeInset.right - inset
            let topEdge = edgeInset.top + inset
            let bottomEdge = size.height - edgeInset.bottom - inset
            
            // 左上 -> 右下
            cgContext.move(to: CGPoint(x: leftEdge, y: topEdge))
            cgContext.addLine(to: CGPoint(x: rightEdge, y: bottomEdge))
            
            // 右上 -> 左下
            cgContext.move(to: CGPoint(x: rightEdge, y: topEdge))
            cgContext.addLine(to: CGPoint(x: leftEdge, y: bottomEdge))
            
            cgContext.strokePath()
        }
    }
}
