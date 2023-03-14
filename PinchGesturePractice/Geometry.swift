//
//  Geometry.swift
//  PinchGesturePractice
//
//  Created by gok on 2023/03/15.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        CGPoint(x: minX + width * 0.5, y: minY + height * 0.5)
    }
    // anchor is ratio relative to the origin of the rect (e.g. x: 0.5, y: 0.5)
    func scaled(by scaleFactor: CGFloat, relativeAnchorRatio: CGPoint) -> CGRect {
        let newWidth = width * scaleFactor
        let newHeight = height * scaleFactor
        let newX = origin.x - (newWidth - width) * relativeAnchorRatio.x
        let newY = origin.y - (newHeight - height) * relativeAnchorRatio.y
        return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }
    // anchor is actual coordinates relative to the origin of the rect (e.g. x: 100, y: 100)
    func scaled(by scaleFactor: CGFloat, relativeAnchor: CGPoint) -> CGRect {
        var value = self
        value.size.width *= scaleFactor
        value.size.height *= scaleFactor
        value.origin.x -= relativeAnchor.x * (scaleFactor - 1)
        value.origin.y -= relativeAnchor.y * (scaleFactor - 1)
        return value
    }
    // anchor is actual coordinates and in the same coordinate space of the rect (e.g. x: 512, y: 384)
    func scaled(by scaleFactor: CGFloat, anchor: CGPoint) -> CGRect {
        var value = self
        let relativeAnchor = CGPoint(x: anchor.x - origin.x, y: anchor.y - origin.y)
        value.size.width *= scaleFactor
        value.size.height *= scaleFactor
        value.origin.x -= relativeAnchor.x * (scaleFactor - 1)
        value.origin.y -= relativeAnchor.y * (scaleFactor - 1)
        return value
    }
}
